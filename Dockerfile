# 雾尼 Muninn 记忆后端（server/only，前端 demo 不参与部署）
# Zeabur 检测到 Dockerfile 后会自动构建；平台注入的 PORT 环境变量会被 http.ts 读取。
FROM node:22-alpine

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --ignore-scripts

# 服务端只依赖 visualizer/engine（类型 + LLM 判定函数），不拷贝整个前端
COPY visualizer/engine ./visualizer/engine
COPY shared ./shared
COPY server ./server

ENV NODE_ENV=production
ENV MUNINN_DATA_DIR=/data

# 启动阶段需要 root 来修正卷属主，装降权工具
RUN apk add --no-cache su-exec

EXPOSE 7300

# 以 root 启动 → 修正卷目录属主 → 降权到 node 跑服务
CMD ["sh", "-c", "mkdir -p /data && chown -R node:node /data && exec su-exec node node --import tsx server/http.ts"]
