{* Вкладки *}
{capture name=tabs}
	{if in_array('settings', $manager->permissions)}<li><a href="?module=SettingsAdmin">Settings</a></li>{/if}
	<li class="active"><a href="?module=ManagersAdmin">Managers</a></li>
{/capture}

{* Title *}
{$meta_title='Managers' scope=parent}


{* Заголовок *}
<div id="header">
	<h1>{$managers_count} {$managers_count|plural:'manager':'managers'}</h1> 	
	<a class="add" href="index.php?module=ManagerAdmin">New manager</a>
</div>

{if $message_error}
<!-- Системное сообщение -->
<div class="message message_error">
	<span class="text">
	{if $message_error=='not_writable'}Set write permission to /backend/.passwd
	{else}{$message_error|escape}{/if}
	</span>
	<a class="button" href="">Back</a>
</div>
<!-- Системное сообщение (The End)-->
{/if}


{if $managers}
<!-- Основная часть -->
<div id="main_list">
	<form id="form_list" method="post">
	<input type="hidden" name="session_id" value="{$smarty.session.id}">
	
		<div id="list">	
			{foreach $managers as $m}
			<div class="row">
		 		<div class="checkbox cell">
					<input type="checkbox" name="check[]" value="{$m->login|escape}" {if $manager->login == $m->login}disabled{/if}/>
				</div>
				<div class="user_name cell">
					<a href="?module=ManagerAdmin&login={$m->login|urlencode}">{$m->login|escape}</a>
				</div>
				<div class="user_email cell">
					<a href="mailto:{$user->name|escape}<{$user->email|escape}>">{$user->email|escape}</a>	
				</div>
				<div class="user_group cell">
					{$groups[$user->group_id]->name}
				</div>
				<div class="icons cell">
					{if $manager->login != $m->login}
					<a class="delete" title="Delete" href="#"></a>
					{/if}
				</div>
				<div class="clear"></div>
			</div>
			{/foreach}
		</div>
	
		<div id="action">
		<label id="check_all" class="dash_link">Select all</label>
	
		<span id=select>
		<select name="action">
			<option value="delete">Delete</option>
		</select>
		</span>
	
		<input id="apply_action" class="button_green" type="submit" value="Apply">
		</div>

	</form>
</div>
{/if}


{literal}
<script>
$(function() {

	// Раскраска строк
	function colorize()
	{
		$("#list div.row:even").addClass('even');
		$("#list div.row:odd").removeClass('even');
	}
	// Раскрасить строки сразу
	colorize();
	
	// Выделить все
	$("#check_all").click(function() {
		$('#list input[type="checkbox"][name*="check"]:not(:disabled)').attr('checked', $('#list input[type="checkbox"][name*="check"]:not(:disabled):not(:checked)').length>0);
	});	

	// Удалить 
	$("a.delete").click(function() {
		$('#list input[type="checkbox"][name*="check"]').attr('checked', false);
		$(this).closest(".row").find('input[type="checkbox"][name*="check"]').attr('checked', true);
		$(this).closest("form").find('select[name="action"] option[value=delete]').attr('selected', true);
		$(this).closest("form").submit();
	});
	
	// Подтверждение удаления
	$("form").submit(function() {
		if($('#list input[type="checkbox"][name*="check"]:checked').length>0)
			if($('select[name="action"]').val()=='delete' && !confirm('Please, confirm deletion'))
				return false;	
	});
});

</script>
{/literal}
