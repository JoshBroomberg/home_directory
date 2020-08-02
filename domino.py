#!/usr/bin/env python3.7

import iterm2
import asyncio
import webbrowser

dominoDir = '~/work/Domino'
mainRepoDir = f"{dominoDir}/domino"

MINIKUBE_UP = [
  "minikube",
  "type: Control Plane",
  "host: Running",
  "kubelet: Running",
  "apiserver: Running",
  "kubeconfig: Configured"
]

# A helper to wait for some output in a terminal to match a string
async def output_matches(session, match, counter_limit=None):
  async with session.get_screen_streamer() as streamer:
    ready = False
    counter = 0
    counter_limit = counter_limit or 10**6
    while ready != True and counter <= counter_limit:
      content = await streamer.async_get()
      for i in range(content.number_of_lines):
        counter += 1
        line = content.line(i)
        if match in line.string:
          return True
  
  return False

async def multiline_output_match(session, match_list, counter_limit=None):
  async with session.get_screen_streamer() as streamer:
    ready = False
    counter = 0
    counter_limit = counter_limit or 10**6
    found_count = 0

    while ready != True and counter <= counter_limit:
      content = await streamer.async_get()
      for i in range(content.number_of_lines):
        counter += 1
        line = content.line(i).string
        for match_target in match_list:
          if match_target in line:
            found_count += 1
            break
      
      if found_count >= len(match_list):
        return True
    
  return False

async def launch(connection):
  # Grab the App instance which is a container to get iTerm2 components from
  app = await iterm2.async_get_app(connection)

  # Get the current terminal window: There can be multiple windows ofc
  window = app.current_terminal_window

  # Also set a manual title to make it clear what this tab is doing
  await window.current_tab.async_set_title("Running: Nucleas + frontend")

  # Create two splits: Left for API, right for frontend
  # You can go crazy with splits here if you need more
  left = window.current_tab.current_session
  right = await left.async_split_pane(vertical=True)

  await left.async_send_text(f"cd {mainRepoDir}\n")
  await left.async_send_text("domino-backend\n")

  # Start frontend by sending text sequences as if we typed them in the terminal
  await right.async_send_text(f"cd {mainRepoDir}\n")
  await right.async_send_text("domino-frontend\n")

  # Create tab for development; I have 1 tab for each service to run vim in
  devtab = await window.async_create_tab()
  await devtab.async_activate()
  await devtab.current_session.async_send_text(f"cd {mainRepoDir}\n")
  await devtab.current_session.async_send_text("git fetch\n")
  await devtab.current_session.async_send_text("git status\n")

  # Wait until frontend process prints a line matching the second argument here
  await output_matches(right, 'webpack: Compiled successfully.')

  # Start firefox with the page open
  webbrowser.get('chrome').open("http://minikube.local.domino.tech/")

async def main(connection):
  # Grab the App instance which is a container to get iTerm2 components from
  app = await iterm2.async_get_app(connection)

  # Get the current terminal window: There can be multiple windows ofc
  window = app.current_terminal_window
  session = window.current_tab.current_session

  ### Validating Minikube state ###

  await window.current_tab.async_set_title("Validating: Minikube")
  await session.async_send_text(f"cd {mainRepoDir}\n")

  await session.async_send_text(f"minikube status\n")
  minikube_status = await multiline_output_match(session, MINIKUBE_UP)

  if minikube_status:
    await session.async_send_text(f"echo minikube status is good. Proceeding...\n")
    await launch(connection)
  else:
    await session.async_send_text(f"echo minikube status is not good. Restarting...\n")
    
    # Restart
    await session.async_send_text(f"./dev/minikube-restart.sh\n")
    await output_matches(right, '=== Restart complete ===')

    # check minikube IP
    await session.async_send_text(f"minikube ip\n")
    minikube_ip = None
    minikube_ip_found = False
    async with session.get_screen_streamer() as streamer:
      while True:
        content = await streamer.async_get()
        for i in range(content.number_of_lines):
          line = content.line(i)
          if "192.168" in line.string:
            minikube_ip = line.string
            minikube_ip_found = True
            break
        
        if minikube_ip_found:
          break
    
    # Check for DNS match
    await session.async_send_text(f"dig minikube.local.domino.tech @localhost\n")
    ip_matches = await output_matches(session, minikube_ip, counter_limit=10**3)
    
    if ip_matches:
      await session.async_send_text(f"echo minikube restart successful. Proceeding...\n")
      await launch(connection)
    else:
      await session.async_send_text(f"echo minikube IP address does not match. Failure.\n")

# And finally we have to tell iterm2 to run this script until it finishes
iterm2.run_until_complete(main)
