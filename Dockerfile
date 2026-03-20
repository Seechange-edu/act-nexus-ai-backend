# 使用Python 3.13官方镜像作为基础镜像
FROM python:3.13-slim

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 安装uv包管理器
RUN pip install uv

# 复制项目文件
COPY pyproject.toml uv.lock ./
COPY requirements.txt ./

# 创建虚拟环境并安装依赖
RUN uv venv
RUN uv pip install -r requirements.txt

# 复制应用代码
COPY . .

# 根据构建环境复制对应的环境文件到容器根目录
# BUILD_ENV 对应 backend/env/<BUILD_ENV>.env，默认使用 dev 配置
ARG BUILD_ENV=dev
COPY env/${BUILD_ENV}.env .env

# 创建非root用户
RUN useradd --create-home --shell /bin/bash app \
    && chown -R app:app /app

# 确保虚拟环境权限正确
RUN chown -R app:app /app/.venv

USER app

# 暴露端口
EXPOSE 8000

# 启动命令
CMD ["/app/.venv/bin/uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

