ARG  PHP_VERSION=8.1
FROM shinsenter/mautic:php${PHP_VERSION}

# ==========================================================

# you may want to install some PHP modules
# e.g: the following line will install imagick, pgsql, solr modules
RUN phpaddmod imagick pgsql solr
RUN apt update && apt install -y npm curl wget nano && npm install -g n && npm cache clean -f && n latest

# ==========================================================

# Control your timezone
ENV TZ="Asia/Bangkok"

# sets GID and UID
ENV PUID=9999
ENV PGID=9999

# sets web server root path
ENV WEBHOME="/var/www/html"


# Add cron jobs
RUN echo "# Segment cron job" >> /etc/crontab && \
    echo "0,15,30,45 * * * * php /var/www/html/bin/console mautic:segments:update --batch-limit=300" >> /etc/crontab && \
    echo "# Campaign cron jobs" >> /etc/crontab && \
    echo "5,20,35,50 * * * * php /var/www/html/bin/console mautic:campaigns:update --batch-limit=300" >> /etc/crontab && \
    echo "10,25,40,55 * * * * php /path/to/mautic/bin/console mautic:campaigns:trigger --batch-limit=100" >> /etc/crontab && \
    echo "# Rescheduled marketing Campaign messages" >> /etc/crontab && \
    echo "*/5 * * * * php /var/www/html/bin/console mautic:messages:send" >> /etc/crontab && \
    echo "# Process Email queue cron job" >> /etc/crontab && \
    echo "*/5 * * * * php /var/www/html/bin/console messenger:consume email" >> /etc/crontab && \
    echo "# Fetch and process Monitored Email cron job" >> /etc/crontab && \
    echo "*/10 * * * * php /var/www/html/bin/console mautic:email:fetch" >> /etc/crontab && \
    echo "# Social Monitoring cron job" >> /etc/crontab && \
    echo "*/15 * * * * php /var/www/html/bin/console mautic:social:monitoring" >> /etc/crontab && \
    echo "# Import Contacts cron job" >> /etc/crontab && \
    echo "0 2 * * * php /var/www/html/bin/console mautic:import" >> /etc/crontab && \
    echo "# Webhooks cron job" >> /etc/crontab && \
    echo "*/15 * * * * php /var/www/html/bin/console mautic:webhooks:process" >> /etc/crontab && \
    echo "# Update MaxMind GeoLite2 IP database cron job" >> /etc/crontab && \
    echo "0 3 1 * * php /var/www/html/bin/console mautic:iplookup:download" >> /etc/crontab && \
    echo "# Clean up old data cron job" >> /etc/crontab && \
    echo "0 4 * * * php /var/www/html/bin/console mautic:maintenance:cleanup --days-old=365 --dry-run --gdpr" >> /etc/crontab && \
    echo "# Send scheduled broadcasts cron job" >> /etc/crontab && \
    echo "# */10 * * * * php /var/www/html/bin/console mautic:broadcasts:send --id=ID --channel=CHANNEL --limit=100 --batch=X" >> /etc/crontab && \
    echo "# Send scheduled Reports cron job" >> /etc/crontab && \
    echo "# 0 5 * * * php /var/www/html/bin/console mautic:reports:scheduler --report=ID" >> /etc/crontab && \
    echo "# Configure Mautic Integration cron jobs" >> /etc/crontab && \
    echo "# Fetch Contacts from the Integration" >> /etc/crontab && \
    echo "0 */2 * * * php /var/www/html/bin/console mautic:integration:fetchleads" >> /etc/crontab && \
    echo "# Push Contact activity to an Integration" >> /etc/crontab && \
    echo "30 */2 * * * php /var/www/html/bin/console mautic:integration:pushactivity" >> /etc/crontab && \
    echo "# Install, update, turn on or turn off Plugins" >> /etc/crontab && \
    echo "0 6 * * * php /var/www/html/bin/console mautic:plugins:reload" >> /etc/crontab
