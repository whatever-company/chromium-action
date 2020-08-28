# https://github.com/GoogleChrome/puppeteer/blob/master/docs/troubleshooting.md#running-puppeteer-in-docker
FROM node:14.8@sha256:a3f4bcda6ea59aaf94ee8f9494ec12008557ef33647a43341a79002b6d7d0eed

# See https://crbug.com/795759
RUN apt-get update && apt-get install -yq libgconf-2-4

# Install latest chrome dev package and fonts to support major charsets (Chinese, Japanese, Arabic, Hebrew, Thai and a few others)
# Note: this installs the necessary libs to make the bundled version of Chromium that Puppeteer
# installs, work.
RUN apt-get update && apt-get install -y wget --no-install-recommends \
	&& wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
	&& sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
	&& apt-get update \
	&& apt-get install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst ttf-freefont \
	--no-install-recommends \
	&& rm -rf /var/lib/apt/lists/* \
	&& apt-get purge --auto-remove -y curl \
	&& rm -rf /src/*.deb


# Always add the --allow-file-access-from-files flag
#
# file:/// URLs are always considered cross domain and fail by default.
# The workaround is to pass the --allow-file-access-from-files flag to
# chromium, however @storybook/addon-storyshots-puppeteer does not let
# us customize the chromium arguments, so we deal with this by calling
# a script instead of the normal chromium launcher that adds this flag.
RUN echo -e '#!/bin/bash\n/usr/bin/google-chrome "$@" --allow-file-access-from-files' > /usr/bin/chromium.sh
RUN chmod +x /usr/bin/chromium.sh

# Uncomment to skip the chromium download when installing puppeteer. If you do,
# you'll need to launch puppeteer with:
#     browser.launch({executablePath: 'google-chrome-unstable'})
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true
