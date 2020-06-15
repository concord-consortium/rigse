# IcoMoon Font/Icons

We use IcoMoon font files for rendering various icons (e.g. arrows, checkmarks, social media logos, etc.).

Icon glyphs are applied to HTML elements by using classes with corresponding CSS rules.

Example: <p><i class="icon icon-email"></i> Email</p>

CSS rules and class names for icons are specified in /src/library/styles/common/icomoon.scss.

## Adding Icons

To add new icons to the IcoMoon font files, use the IcoMoon app at icomoon.io/app.

First, create a project, then import icomoon.svg using the Import Icons button and select all the icons imported.

Next, add additional icons by selecting from the default IcoMoon set or importing custom icons in SVG format.

Make sure the character codes for existing icons (as shown on the Generate Font tab) haven't diverged from existing character codes in /src/library/styles/common/icomoon.scss.

Finally, download the font package and update the icomoon font files in /src/library/assets/fonts
