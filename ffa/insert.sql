CREATE TABLE `ffa_users` (
  `id` int(11) NOT NULL,
  `url` varchar(255) DEFAULT 'http://i.imgur.com/gsnPQRw.png',
  `identifier` varchar(255) NOT NULL,
  `steamid` longtext DEFAULT NULL,
  `name` longtext NOT NULL,
  `steamname` longtext DEFAULT NULL,
  `kills` int(11) NOT NULL DEFAULT 0,
  `deaths` int(11) NOT NULL DEFAULT 0,
  `playtime` varchar(255) DEFAULT '0',
  `loadout` varchar(255) DEFAULT '"[]"',
  `options` varchar(255) DEFAULT '"[]"'
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `ffa_users`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `ffa_users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;
COMMIT;

CREATE TABLE `ffa_chart` (
  `id` int(11) NOT NULL,
  `chart` longtext DEFAULT NULL,
  `categories` longtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `ffa_chart`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `ffa_chart`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;
COMMIT;
