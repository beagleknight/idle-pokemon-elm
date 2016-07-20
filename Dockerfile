FROM node:latest
MAINTAINER david.morcillo@gmail.com

RUN npm install -g elm

WORKDIR /code

EXPOSE 8000

CMD ["elm", "reactor", "-a", "0.0.0.0"]