<?php
session_start();
?>

<html>
<head>
	<title>Восстановления пароля администратора</title>
	<meta http-equiv="Content-Type" content="text/html; charset=utf8" />
	<meta http-equiv="Content-Language" content="ru" />
</head>
<style>
  h1{font-size:26px; font-weight:normal}
  p{font-size:19px;}
  input{font-size:18px;}
  p.error{color:red;}
  div.maindiv{width: 600px; height: 300px; position: relative; left: 50%; top: 100px; margin-left: -300px; }
</style>
<body>
<div style='width:100%; height:100%;'> 
  <div class="maindiv">

<?php
require_once('api/Backend.php');
$backend = new Backend();

// Если пришли по ссылке из письма
if($c = $backend->request->get('code'))
{
	// Код не совпадает - прекращяем работу
	if(empty($_SESSION['admin_password_recovery_code']) || empty($c) || $_SESSION['admin_password_recovery_code'] !== $c)
	{
		header('Location:password.php');
		exit();
	}
	
	// IP не совпадает - прекращяем работу
	if(empty($_SESSION['admin_password_recovery_ip'])|| empty($_SERVER['REMOTE_ADDR']) || $_SESSION['admin_password_recovery_ip'] !== $_SERVER['REMOTE_ADDR'])
	{
		header('Location:password.php');
		exit();
	}
	
	// Если запостили пароль
	if($new_password = $backend->request->post('new_password'))
	{
		// Файл с паролями
		$passwd_file = $backend->config->root_dir.'backend/.passwd';
		
		// Удаляем из сесси код, чтобы больше никто не воспользовался ссылкой
		unset($_SESSION['admin_password_recovery_code']);
		unset($_SESSION['admin_password_recovery_ip']);

		// Если в файлы запрещена запись - предупреждаем об этом
		if(!is_writable($passwd_file))
		{
			print "
				<h1>Восстановление пароля администратора</h1>
				<p class='error'>
				Файл /backend/.passwd недоступен для записи.
				</p>
				<p>Вам нужно зайти по FTP и изменить права доступа к этому файлу, после чего повторить процедуру восстановления пароля.</p>
			";
		}
		else
		{
			// Новый логин и пароль
			$new_login = $backend->request->post('new_login');
			$new_password = $backend->request->post('new_password');
			if(!$backend->managers->update_manager($new_login, array('password'=>$new_password)))
				$backend->managers->add_manager(array('login'=>$new_login, 'password'=>$new_password));
			
			print "
				<h1>Восстановление пароля администратора</h1>
				<p>
				Новый пароль установлен
				</p>
				<p>
				<a href='".$backend->root_url."/backend/index.php?module=ManagersAdmin'>Перейти в панель управления</a>
				</p>
			";
		}
	}
	else
	{
	// Форма указалия нового логина и пароля
	print "
		<h1>Восстановление пароля администратора</h1>
		<p>
		<form method=post>
			Новый логин:<br><input type='text' name='new_login'><br><br>
			Новый пароль:<br><input type='password' name='new_password'><br><br>
			<input type='submit' value='Сохранить логин и пароль'>
		</form>
		</p>
		";
	}
}
else
{
	print "
		<h1>Восстановление пароля администратора</h1>
		<p>
		Введите email администратора
		<form method='post' action='".$backend->root_url."/password.php'>
			<input type='text' name='email'>
			<input type='submit' value='Восстановить пароль'>
		</form>
		</p>
	";

	$admin_email = $backend->settings->admin_email;
	
	if(isset($_POST['email']))
	{
		if($_POST['email'] === $admin_email)
		{
			$code = $backend->config->token(mt_rand(1, mt_getrandmax()).mt_rand(1, mt_getrandmax()).mt_rand(1, mt_getrandmax()));
			$_SESSION['admin_password_recovery_code'] = $code;
			$_SESSION['admin_password_recovery_ip'] = $_SERVER['REMOTE_ADDR'];
			
			$message = 'Вы или кто-то другой запросил ссылку на восстановление пароля администратора.<br>';
			$message .= 'Для смены пароля перейдите по ссылке '.$backend->config->root_url.'/password.php?code='.$code.'<br>';
			$message .= 'Если письмо пришло вам по ошибке, проигнорируйте его.';
			
			$backend->notify->email($admin_email, 'Восстановление пароля администратора '.$backend->settings->site_name, $message, $backend->settings->notify_from_email);
		}
		print "Вам отправлена ссылка для восстановления пароля. Если письмо вам не пришло, значит вы неверно указали email или что-то не так с хостингом";
	}

}
?>

  </div>
</div>
</body>
</html>
