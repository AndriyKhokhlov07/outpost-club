{* Вкладки *}
{capture name=tabs}
	{if in_array('settings', $manager->permissions)}<li><a href="?module=SettingsAdmin">Settings</a></li>{/if}
	<li class="active"><a href="?module=ManagersAdmin">Managers</a></li>
{/capture}

{if $m->login}
{$meta_title = $m->login scope=parent}
{else}
{$meta_title = 'New manager' scope=parent}
{/if}

{* On document load *}
<script src="design/js/jquery/jquery.js"></script>
<script src="design/js/jquery/jquery-ui.min.js"></script>
<script>
{literal}
$(function() {
	// Выделить все
	$("#check_all").click(function() {
		$('input[type="checkbox"][name*="permissions"]:not(:disabled)').attr('checked', $('input[type="checkbox"][name*="permissions"]:not(:disabled):not(:checked)').length>0);
	});

	{/literal}{if $m->login}$('#password_input').hide();{/if}{literal}
	$('#change_password').click(function() {
		$('#password_input').show();
	});
		
});
{/literal}
</script>


{if $message_success}
<!-- Системное сообщение -->
<div class="message message_success">
	<span class="text">{if $message_success=='added'}Manager created{elseif $message_success=='updated'}Manager updated{else}{$message_success|escape}{/if}</span>
	{if $smarty.get.return}
	<a class="button" href="{$smarty.get.return}">Back</a>
	{/if}
</div>
<!-- Системное сообщение (The End)-->
{/if}

{if $message_error}
<!-- Системное сообщение -->
<div class="message message_error">
	<span class="text">
	{if $message_error=='login_exists'}Manager with the same login already exists
	{elseif $message_error=='empty_login'}Enter login
	{elseif $message_error=='not_writable'}Set write permission to /backend/.passwd
	{else}{$message_error|escape}{/if}
	</span>
	<a class="button" href="">Back</a>
</div>
<!-- Системное сообщение (The End)-->
{/if}


<!-- Основная форма -->
<form method=post id=product enctype="multipart/form-data">
<input type=hidden name="session_id" value="{$smarty.session.id}">
	<div id="name">
		Login:
		<input class="name" name="login" type="text" value="{$m->login|escape}" maxlength="32"/> 
		<input name="old_login" type="hidden" value="{$m->login|escape}"/>
		Password:
		{if $m->login}<a class="dash_link"id="change_password">edit</a>{/if}
		<input id="password_input" class="name" name="password" type="password" value=""/> 
	</div> 

	<!-- Левая колонка -->
	<div id="column_left">
		
		<h2>Permissions:</h2>
		<div class="block"><label id="check_all" class="dash_link">Select all</label></div>
		<!-- Параметры  -->
		<div class="block">
			<ul>
			
				{$perms = [
					'pages'      =>'Pages',
					'blog'       =>'Blog',
                    'galleries'  =>'Galleries',
					'comments'   =>'Comments',
					'feedbacks'  =>'Feedbacks',
					'design'     =>'Design',
					'settings'   =>'Settings',
					'managers'   =>'Managers',
					'issues' 	 =>'Issues',
					'products'   =>'Products',
					'categories' =>'Categories',
					'brands'     =>'Brands',
					'features'   =>'Features',
					'orders'     =>'Orders',
					'labels'     =>'Orders labels',
					'currency'   =>'Currencies',
					'delivery'   =>'Shipping',
					'payment'    =>'Payment',
					'users'      =>'Guests',
					'inventories'=>'Restocking'
				]}

				
				
				{foreach $perms as $p=>$name}
				<li><label class=property for="{$p}">{$name}</label>
				<input id="{$p}" name="permissions[]" class="backend_inp" type="checkbox" value="{$p}"
				{if $m->permissions && in_array($p, $m->permissions)}checked{/if} {if $m->login==$manager->login}disabled{/if}/></li>
				{/foreach}

				<li>
					<br>
					<h3>Pages:</h3>
				</li>
				{foreach $menus as $mn}
				<li><label class=property for="menu_{$mn->id}">{$mn->name}</label>
				<input id="menu_{$mn->id}" name="permissions[]" class="backend_inp" type="checkbox" value="menu_{$mn->id}"
				{if $m->permissions && in_array("menu_`$mn->id`", $m->permissions)}checked{/if} {if $m->login==$manager->login}disabled{/if}/></li>
				{/foreach}
				
				
				
			</ul>
			
		</div>
		<!-- Параметры (The End)-->
		

			
	</div>
	<!-- Левая колонка (The End)--> 
	
	
	<input class="button_green button_save" type="submit" name="" value="Save" />
	
</form>
<!-- Основная форма (The End) -->
