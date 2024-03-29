<?php

session_start();

require_once('../../api/Backend.php');

$backend = new Backend();

if(!$backend->managers->access('design'))
	return false;

// Проверка сессии для защиты от xss
if(!$backend->request->check_session())
{
	trigger_error('Session expired', E_USER_WARNING);
	exit();
}
$content = $backend->request->post('content');
$template = $backend->request->post('template');
$theme = $backend->request->post('theme', 'string');

if(pathinfo($template, PATHINFO_EXTENSION) != 'tpl')
	exit();

$file = $backend->config->root_dir.'design/'.$theme.'/html/'.$template;
if(is_file($file) && is_writable($file) && !is_file($backend->config->root_dir.'design/'.$theme.'/locked'))
	file_put_contents($file, $content);

$result= true;
header("Content-type: application/json; charset=UTF-8");
header("Cache-Control: must-revalidate");
header("Pragma: no-cache");
header("Expires: -1");		
$json = json_encode($result);
print $json;