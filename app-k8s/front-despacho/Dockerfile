# Fase 1: Compilar la SPA de React con Node
FROM node:18-alpine AS build
WORKDIR /app

# Copiar archivos de empaquetado e instalar dependencias
COPY package*.json ./
RUN npm install

# Copiar el resto del código y transpilar (generará la carpeta /dist)
COPY . .
RUN npm run build

# Fase 2: Servidor web de producción Nginx
FROM nginx:alpine

# Copiar la configuración personalizada de Nginx del profe
COPY default.conf /etc/nginx/conf.d/default.conf

# Copiar los archivos compilados de React desde la fase build hacia la ruta de Nginx
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]