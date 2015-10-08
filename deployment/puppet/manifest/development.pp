Yumrepo <| |> -> Package <| |>

# Yum manifest
include ::yum
class { 'yum::repo::repoforge': }
class { 'yum::repo::epel': }
class { 'yum::repo::remi': }

# Nginx manifest
include ::nginx

# Php
class { 'yum::repo::remi_php56': }
include ::php