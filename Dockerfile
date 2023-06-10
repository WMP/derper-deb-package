FROM ghcr.io/slchris/derp-server:v1
# WORKDIR /go/src/github.com/alexellis/href-counter/
# RUN go get -d -v golang.org/x/net/html  
# COPY app.go ./
# RUN CGO_ENABLED=0 go build -a -installsuffix cgo -o app .

WORKDIR /

# Use the base image of the desired operating system
FROM debian:latest

# Install the necessary tools and libraries
RUN apt-get update && apt-get install -y \
    build-essential \
    dpkg-dev \
    golang \
    && rm -rf /var/lib/apt/lists/*



# Create directories for the DEB package
RUN mkdir -p /tailscale-derp/DEBIAN \
    /tailscale-derp/usr/sbin \
    /output

# Copy the program and systemd unit file to the appropriate directories
# RUN cp derper /tailscale-derp/usr/sbin
COPY --from=0 /app/derper /tailscale-derp/usr/sbin
COPY tailscale-derp.service /tailscale-derp/etc/systemd/system/
COPY tailscale-derp.default /tailscale-derp/etc/default/tailscale-derp
COPY tailscale-derp.postinst /tailscale-derp/DEBIAN/postinst
COPY tailscale-derp.install /tailscale-derp/DEBIAN/
COPY derper.control /tailscale-derp/DEBIAN/control

# Set permissions and owner for the files
RUN chmod 755 /tailscale-derp/DEBIAN/postinst \
    && chown -R root:root /tailscale-derp

# Create the conffiles file and add the paths of the configuration files
RUN echo "/etc/default/tailscale-derp" >> /tailscale-derp/DEBIAN/conffiles


# Build the DEB package
RUN dpkg-deb --build /tailscale-derp

# Optionally, you can place the DEB package in a different location
# Copy the DEB package to another directory, e.g., /output
CMD ["cp", "/tailscale-derp.deb", "/output/"]"
# # You can add additional instructions, such as running the program or other configurations

# # The CMD command can be used to run the program after creating the container (optional)
# CMD ["/tailscale-derp/usr/sbin/derper"]
# CMD ["/bin/bash"]