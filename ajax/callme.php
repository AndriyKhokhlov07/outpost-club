<?
chdir('..');
require_once('api/Backend.php');
$backend = new Backend();

if($backend->request->post('name') && $backend->request->post('phone')){
	$callme->name    = $backend->request->post('name');
	$callme->phone   = $backend->request->post('phone');
	$callme->pageurl = $backend->request->post('pageurl');
	$callme->date    = date("d.m.Y G:i");
		
	$backend->design->assign('callme', $callme);
	
	// Отправляем письмо
	$email_template = $backend->design->fetch($backend->config->root_dir.'backend/design/html/email_callme_admin.tpl');
	$subject = $backend->design->get_var('subject');
	if($backend->notify->email($backend->settings->callme_email, $subject, $email_template, $backend->settings->notify_from_email))
		echo 1;
	else
		echo 0;
}