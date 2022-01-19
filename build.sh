#! /bin/sh

docker build -t bkbhub/tor-scraper:latest .

docker push bkbhub/tor-scraper:latest
