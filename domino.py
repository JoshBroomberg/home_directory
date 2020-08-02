#!/usr/bin/env python3.7

import iterm2
import asyncio
import webbrowser

dominoDir = '~/work/Domino'
mainRepoDir = f"{dominoDir}/domino"

# A helper to wait for some output in a terminal to match a string
async def output_matches(session, match):
  async with session.get_screen_streamer() as streamer:
    ready = False
    counter = 0
    while ready != True and counter <= 10**6:
      content = await streamer.async_get()
      for i in range(content.number_of_lines):
        line = content.line(i)
        if match in line.string:
          return

async def main(connection):
  # Grab the App instance which is a container to get iTerm2 components from
  app = await iterm2.async_get_app(connection)

  # Get the current terminal window: There can be multiple windows ofc
  window = app.current_terminal_window

  # Create two splits: Left for API, right for frontend
  # You can go crazy with splits here if you need more
  left = window.current_tab.current_session
  right = await left.async_split_pane(vertical=True)

  # Also set a manual title to make it clear what this tab is doing
  await window.current_tab.async_set_title("Running: Nucleas + frontend")

  # Start API by sending text sequences as if we typed them in the terminal
  await left.async_send_text(f"cd {mainRepoDir}\n")
  await left.async_send_text("domino-backend\n")

  # Start frontend by sending text sequences as if we typed them in the terminal
  await right.async_send_text(f"cd {mainRepoDir}\n")
  await right.async_send_text("domino-frontend\n")

  # Create tab for development; I have 1 tab for each service to run vim in
  frontend = await window.async_create_tab()
  await frontend.async_activate()
  await frontend.current_session.async_send_text(f"cd {mainRepoDir}\n")
  await frontend.current_session.async_send_text("git status\n")

  # Wait until frontend process prints a line matching the second argument here
  await output_matches(right, 'webpack: Compiled successfully.')

  # Start firefox with the page open
  webbrowser.get('chrome').open("http://minikube.local.domino.tech/")

# And finally we have to tell iterm2 to run this script until it finishes
iterm2.run_until_complete(main)
