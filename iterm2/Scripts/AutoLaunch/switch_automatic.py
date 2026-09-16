#!/usr/bin/env python3

# Originally from https://gist.github.com/FradSer/de1ca0989a9d615bd15dc6eaf712eb93?permalink_comment_id=3649575#gistcomment-3649575

import asyncio
import logging
import sys
import time

import iterm2

logger = logging.getLogger("iterm2.switch_automatic")

def allSessions(app: iterm2.App):
    for window in app.terminal_windows:
        for tab in window.tabs:
            for session in tab.sessions:
                yield (session, window, tab)

async def changeTheme(theme_parts: list[str], connection: iterm2.Connection, app: iterm2.App):
    # Themes have space-delimited attributes, one of which will be light or dark.
    preset = await iterm2.ColorPreset.async_get(connection, "TuesdayThursday")
    if "dark" in theme_parts:
        # preset = await iterm2.ColorPreset.async_get(connection, "Tomorrow Night")
        blending = 8
    else:
        # preset = await iterm2.ColorPreset.async_get(connection, "Tomorrow")
        blending = 17

    # Update the list of all profiles and iterate over them.
    profiles = await iterm2.PartialProfile.async_query(connection)
    main_profiles = {profile.guid for profile in profiles}
    for partial in profiles:
        # Fetch the full profile and then set the color preset in it.
        # profile = await partial.async_get_full_profile()
        await partial.async_set_color_preset(preset)
        await partial.async_set_blend(blending / 100.0)
    for session, _tab, _window in allSessions(app):
        profile = await session.async_get_profile()
        if profile and profile.guid not in main_profiles:
            await profile.async_set_color_preset(preset)


async def main(connection):
    # Set color scheme correctly at app start
    app = await iterm2.async_get_app(connection)
    parts = await app.async_get_theme()
    theme = " ".join(parts)
    logger.info(f"Started with theme {theme}")
    print(f"Started with theme {theme}")
    await changeTheme(parts, connection, app)

    async with iterm2.VariableMonitor(
        connection, iterm2.VariableScopes.APP, "effectiveTheme", None
    ) as mon:
        while True:
            # Block until theme changes
            theme = await mon.async_get()
            logger.info(f"Switched to theme {theme}")
            print(f"Switched to theme {theme}")
            parts = theme.split(" ")
            await changeTheme(parts, connection)


try:
    iterm2.run_forever(main, retry=True)
except asyncio.exceptions.TimeoutError as err:
    print("warn", err, file=sys.stderr)
    time.sleep(5)
    iterm2.run_forever(main, retry=True)
