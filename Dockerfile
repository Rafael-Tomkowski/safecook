# Etapa única: só servir os arquivos estáticos do Flutter web
FROM nginx:alpine

# Remove o site padrão do nginx
RUN rm -rf /usr/share/nginx/html/*

# Copia o build do Flutter para a pasta pública do nginx
COPY build/web/ /usr/share/nginx/html/

# (Opcional) configurar gzip / cache -> dá pra mexer depois se quiser
# COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
