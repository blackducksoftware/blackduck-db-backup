# blackduck-db-backup

Provides scheduled database backup allowing or retention of historical data without overusing storage space.

This procedure is applicable to HUB running postgres container.

Database dumps performed on six-hour, daily, weekly and monthly basis.

Different backup types are staggered to ensure they do not start at the same time.

Fixed number of each backup would be retained allowing recovery going back N six hour terms, N days, N weeks or N months.

Setup consists of crontab entries and a backup script.
