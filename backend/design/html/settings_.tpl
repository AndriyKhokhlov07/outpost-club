{capture name=tabs}
	<li class="active"><a href="?module=SettingsAdmin">Settings</a></li>
	{if in_array('managers', $manager->permissions)}<li><a href="?module=ManagersAdmin">Managers</a></li>{/if}
{/capture}
 
{$meta_title = "Настройки" scope=parent}

{if $message_success}
<!-- Системное сообщение -->
<div class="message message_success">
	<span class="text">{if $message_success == 'saved'}Settings saved{/if}</span>
	{if $smarty.get.return}
	<a class="button" href="{$smarty.get.return}">Back</a>
	{/if}
</div>
<!-- Системное сообщение (The End)-->
{/if}

{if $message_error}
<!-- Системное сообщение -->
<div class="message message_error">
	<span class="text">{if $message_error == 'watermark_is_not_writable'}Set writable permissions to the file {$config->watermark_file}{/if}</span>
	<a class="button" href="">Back</a>
</div>
<!-- Системное сообщение (The End)-->
{/if}
			

<!-- Основная форма -->
<form method=post id=product enctype="multipart/form-data">
<input type=hidden name="session_id" value="{$smarty.session.id}">
			
		<!-- Параметры -->
		<div class="block">
			<h2>Website settings</h2>
			<ul>
				<li><label class=property>Store name</label><input name="site_name" class="backend_inp" type="text" value="{$settings->site_name|escape}" /></li>
				<li><label class=property>Company name</label><input name="company_name" class="backend_inp" type="text" value="{$settings->company_name|escape}" /></li>
				<li><label class=property>Date format</label><input name="date_format" class="backend_inp" type="text" value="{$settings->date_format|escape}" /></li>
				<li><label class=property>Password remind email</label><input name="admin_email" class="backend_inp" type="text" value="{$settings->admin_email|escape}" /></li>
			</ul>
		</div>
		<div class="block layer">
			<h2>Notification settings</h2>
			<ul>
				<li><label class=property>Comments notificatoion email</label><input name="comment_email" class="backend_inp" type="text" value="{$settings->comment_email|escape}" /></li>
                <!-- <li><label class=property>Оповещение обратного звонка</label><input name="callme_email" class="backend_inp" type="text" value="{$settings->callme_email|escape}" /></li>
                <li><label class=property>Оповещение о подписке</label><input name="subscription_email" class="backend_inp" type="text" value="{$settings->subscription_email|escape}" /></li> -->
				<li><label class=property>Website email</label><input name="notify_from_email" class="backend_inp" type="text" value="{$settings->notify_from_email|escape}" /></li>
			</ul>
		</div>
		<!-- Параметры (The End)-->

		<input class="button_green button_save" type="submit" name="save" value="Save" />
			
	<!-- Левая колонка свойств товара (The End)--> 
	
</form>
<!-- Основная форма (The End) -->

{literal}
<script>
$(function() {
	$('#change_password_form').hide();
	$('#change_password').click(function() {
		$('#change_password_form').show();
	});
});
</script>
{/literal}
