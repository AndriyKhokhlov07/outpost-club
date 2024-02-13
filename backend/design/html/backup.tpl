{* Вкладки *}
{capture name=tabs}
	{if in_array('import', $manager->permissions)}<li><a href="index.php?module=ImportAdmin">Import</a></li>{/if}
	{if in_array('export', $manager->permissions)}<li><a href="index.php?module=ExportAdmin">Export</a></li>{/if}
	<li class="active"><a href="index.php?module=BackupAdmin">Backup</a></li>		
{/capture}

{* Title *}
{$meta_title='Backup' scope=parent}

{* Заголовок *}
<div id="header">
	<h1>Backup</h1>
	{if $message_error != 'no_permission'}
	<a class="add" href="">Create Backup</a>
	<form id="hidden" method="post">
		<input type="hidden" name="session_id" value="{$smarty.session.id}">
		<input type="hidden" name="action" value="">
		<input type="hidden" name="name" value="">
	</form>
	{/if}
</div>	

{if $message_success}
<!-- Системное сообщение -->
<div class="message message_success">
	<span class="text">{if $message_success == 'created'}Backup created{elseif $message_success == 'restored'}Backup recovered{/if}</span>
	{if $smarty.get.return}
	<a class="button" href="{$smarty.get.return}">Return</a>
	{/if}
</div>
<!-- Системное сообщение (The End)-->
{/if}

{if $message_error}
<!-- Системное сообщение -->
<div class="message message_error">
	<span class="text">
	{if $message_error == 'no_permission'}Set write permissions to a folder {$backup_files_dir}
	{else}{$message_error}{/if}
	</span>
</div>
<!-- Системное сообщение (The End)-->
{/if}

{if $backups}
<div id="main_list">

	<form id="list_form" method="post">
	<input type="hidden" name="session_id" value="{$smarty.session.id}">

		<div id="list">			
			{foreach $backups as $backup}
			<div class="row">
				{if $message_error != 'no_permission'}
		 		<div class="checkbox cell">
					<input type="checkbox" name="check[]" value="{$backup->name}"/>				
				</div>
				{/if}
				<div class="name cell">
	 				<a href="files/backup/{$backup->name}">{$backup->name}</a>
					({if $backup->size>1024*1024}{($backup->size/1024/1024)|round:2} МБ{else}{($backup->size/1024)|round:2} КБ{/if})
				</div>
				<div class="icons cell">
					{if $message_error != 'no_permission'}
					<a class="delete" title="delete" href="#"></a>
					{/if}
		 		</div>
				<div class="icons cell">
					<a class="restore" title="Recover this backup" href="#"></a>
				</div>
		 		<div class="clear"></div>
			</div>
			{/foreach}
		</div>
		
		{if $message_error != 'no_permission'}
		<div id="action">
		<label id="check_all" class="dash_link">Select all</label>
	
		<span id="select">
		<select name="action">
			<option value="delete">Delete</option>
		</select>
		</span>
	
		<input id="apply_action" class="button_green" type="submit" value="Apply">
		</div>
		{/if}
	
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
		$('#list input[type="checkbox"][name*="check"]').attr('checked', $('#list input[type="checkbox"][name*="check"]:not(:checked)').length>0);
	});	

	// Удалить 
	$("a.delete").click(function() {
		$('#list input[type="checkbox"][name*="check"]').attr('checked', false);
		$(this).closest(".row").find('input[type="checkbox"][name*="check"]').attr('checked', true);
		$(this).closest("form").find('select[name="action"] option[value=delete]').attr('selected', true);
		$(this).closest("form").submit();
	});

	// Восстановить 
	$("a.restore").click(function() {
		file = $(this).closest(".row").find('[name*="check"]').val();
		$('form#hidden input[name="action"]').val('restore');
		$('form#hidden input[name="name"]').val(file);
		$('form#hidden').submit();
		return false;
	});

	// Создать бекап 
	$("a.add").click(function() {
		$('form#hidden input[name="action"]').val('create');
		$('form#hidden').submit();
		return false;
	});

	$("form#hidden").submit(function() {
		if($('input[name="action"]').val()=='restore' && !confirm('Current data will be lost. Confirm recovery'))
			return false;	
	});
	
	$("form#list_form").submit(function() {
		if($('select[name="action"]').val()=='delete' && !confirm('Confirm removal'))
			return false;	
	});
	

});

</script>
{/literal}