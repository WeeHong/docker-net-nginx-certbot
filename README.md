# Deploy .NET application using Docker with Nginx and Let's Encrypt
This repository is for my learning purpose of using Docker.

This project managed to bundle up everything with one-click.

A big thanks to Tony Sneed and Philipp for their guide.

## References
- https://medium.com/@pentacent/nginx-and-lets-encrypt-with-docker-in-less-than-5-minutes-b4b8a60d3a71
- https://blog.tonysneed.com/2019/10/13/enable-ssl-with-asp-net-core-using-nginx-and-docker/
- https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/linux-nginx?view=aspnetcore-6.0

## Prerequisite
- Hosting service (Digital Ocean, AWS, GCP, etc)
- DNS (Namecheap, GoDaddy, etc)

## How to use
- Deploy this entire application to instance
- Run `chmod u+x start.sh`
- Then `./start.sh`
- Check your website from `<domain>/weatherforecast`