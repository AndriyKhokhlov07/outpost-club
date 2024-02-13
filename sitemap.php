<?php

require_once('api/Backend.php');
$backend = new Backend();

header("Content-type: text/xml; charset=UTF-8");
print '<?xml version="1.0" encoding="UTF-8"?>'."\n";
print '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'."\n";

// Главная страница
$url = $backend->config->root_url;
$lastmod = date("Y-m-d");
print "\t<url>"."\n";
print "\t\t<loc>$url</loc>"."\n";
print "\t\t<lastmod>$lastmod</lastmod>"."\n";
print "\t</url>"."\n";

// Страницы
foreach($backend->pages->get_pages() as $p)
{
	if($p->visible && in_array($p->menu_id, array(1, 2, 5)) && $p->url!='current-members')
	{
		$url = $backend->config->root_url.'/'.esc($p->url);
		print "\t<url>"."\n";
		print "\t\t<loc>$url</loc>"."\n";
		print "\t</url>"."\n";
	}
}

// Блог
foreach($backend->blog->get_posts(array('visible'=>1, 'type'=>1)) as $p)
{
	$url = $backend->config->root_url.'/blog/'.esc($p->url);
	print "\t<url>"."\n";
	print "\t\t<loc>$url</loc>"."\n";
	print "\t</url>"."\n";
}


print '</urlset>'."\n";

function esc($s)
{
	return(htmlspecialchars($s, ENT_QUOTES, 'UTF-8'));	
}