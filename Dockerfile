# syntax=docker/dockerfile:1
FROM ruby:3.3.1-slim AS builder

ENV BUNDLE_PATH=/gems \
    RAILS_ENV=production \
    NODE_ENV=production \
    RAILS_SERVE_STATIC_FILES=true \
    RAILS_LOG_TO_STDOUT=true

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential \
  libpq-dev \
  git \
  curl \
  ca-certificates \
  nodejs \
  libvips-dev \
  tzdata \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Cache gems
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle config set without 'development test' && bundle install --jobs 4 --retry 3

# Copy app and compile assets
COPY . .
# Set a build-time SECRET_KEY_BASE so Rails can precompile assets without requiring credentials
ENV SECRET_KEY_BASE=precompile_dummy
RUN bundle exec rails assets:precompile

# Development image (includes development/test gems for local dev)
FROM ruby:3.3.1-slim AS dev

ENV BUNDLE_PATH=/gems \
    RAILS_ENV=development \
    NODE_ENV=development

# Install build/run dependencies for development image
RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential \
  libpq-dev \
  git \
  curl \
  ca-certificates \
  nodejs \
  libvips-dev \
  tzdata \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle config set without "" && bundle install --jobs 4 --retry 3

COPY . .

EXPOSE 3000

CMD ["bin/dev"]

# -- Runtime image --
FROM ruby:3.3.1-slim

ENV RAILS_ENV=production \
    RAILS_SERVE_STATIC_FILES=true \
    RAILS_LOG_TO_STDOUT=true \
    PORT=3000 \
    BUNDLE_PATH=/gems

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
  libpq5 \
  curl \
  ca-certificates \
  nodejs \
  libvips42 || true \
  tzdata \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy gems from builder
COPY --from=builder /gems /gems
ENV PATH="/gems/bin:$PATH"

# Copy app from builder (includes precompiled assets)
COPY --from=builder /app /app

# Copy entrypoint
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 CMD curl -f http://localhost:${PORT:-3000}/up || exit 1

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
