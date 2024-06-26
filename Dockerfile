# -------------------------------------------------------------------
# Minimal dockerfile from alpine base
#
# Instructions:
# =============
# 1. Create an empty directory and copy this file into it.
#
# 2. Create image with: 
#   docker build --tag timeoff:latest .
#
# 3. Run with: 
#   docker run -d -p 3000:3000 --name alpine_timeoff timeoff
#
# 4. Login to running container (to update config (vi config/app.json): 
#   docker exec -ti --user root alpine_timeoff /bin/sh
# --------------------------------------------------------------------

# Stage 1: Install dependencies
FROM node:14-alpine as dependencies

# Install necessary packages including build tools and Python
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    bash

# Set work directory and copy package.json
WORKDIR /app
COPY package.json package-lock.json ./

# Install node modules
RUN npm install

# Stage 2: Build the final image
FROM node:14-alpine

LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.docker.cmd="docker run -d -p 3000:3000 --name alpine_timeoff"

# Install necessary packages
RUN apk add --no-cache \
    vim

# Create a non-root user
RUN adduser --system app --home /app
USER app

# Set work directory
WORKDIR /app

# Copy application files
COPY . .

# Copy node modules from the dependencies stage
COPY --from=dependencies /app/node_modules ./node_modules

# Expose the application port
EXPOSE 3000

# Start the application
CMD ["npm", "start"]