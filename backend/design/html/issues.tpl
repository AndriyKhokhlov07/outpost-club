{* Вкладки *}
{capture name=tabs}
	{if in_array('issues', $manager->permissions)}
		<li><a href="index.php?module=UsersAdmin">Guests</a></li>
		<li><a href="index.php?module=MoveInAdmin">Move In</a></li>
		<li><a href="index.php?module=FarewellAdmin">Farewell</a></li>
	{/if}
	<li class="active"><a href="index.php?module=IssuesAdmin">Technical Issues</a></li>
	{if in_array("menu_12", $manager->permissions)}
		<li><a href='?module=PagesAdmin&menu_id=12'>For House Leader</a></li>
	{/if}
{/capture}

{* Title *}
{$meta_title='Technical Issues' scope=parent}



{* Заголовок *}
<div id="header">
	{if $issues|count>0}
	<h1>{$issues|count} technical {$issues|count|plural:'issue':'issues'}</h1> 	
	{else}
	<h1>No technical issues</h1> 	
	{/if}
	
	<a class="add" href="{url module=IssueAdmin return=$smarty.server.REQUEST_URI}">Add new issue</a>
</div>

{if $issues}
<!-- Основная часть -->
<div id="main_list">

	<form id="form_list" method="post">
	<input type="hidden" name="session_id" value="{$smarty.session.id}">
	
		<div id="list">	
			{foreach $issues as $issue}
			<div class="{if !$issue->visible}invisible{/if} row">
		 		<div class="checkbox cell">
					<input type="checkbox" name="check[]" value="{$issue->id}"/>				
				</div>
				<div class="issue_name cell">
					{if $issue->house_id && $rooms[$issue->house_id]}
						<div class="sm">{$rooms[$issue->house_id]->name|escape}</div>
					{/if}
					<a href="index.php?module=IssueAdmin&id={$issue->id}">
						{$issue->assignment|escape|truncate:50:'…':true:true}
					</a>
					<div class="sm">{$issue->date_start|date} at {$issue->date_start|time}</div>
				</div>

				<div class="user_status cell">
					{$statuses[$issue->status]}
				</div>


				<div class="icons cell">
					<a class="enable" title="Активен" href="#"></a>
					<a class="delete" title="Удалить" href="#"></a>
				</div>
				<div class="clear"></div>
			</div>
			{/foreach}
		</div>
	
		<div id="action">
		<label id="check_all" class="dash_link">Select all</label>
	
		<span id=select>
		<select name="action">
			<option value="disable">Disable</option>
			<option value="enable">Enable</option>
			<option value="delete">Delete</option>
		</select>
		</span>
	
		<input id="apply_action" class="button_green" type="submit" value="Apply">
		</div>

	</form>
	
</div>
{/if}

 <!-- Меню -->
<div id="right_menu">
	{function name=houses_tree}
	{if $houses}
	<ul>
		{if $houses[0]->parent_id == 0}
			<li {if !$house->id}class="selected"{/if}><a href="{url house_id=null}">All houses</a></li>	
		{/if}
		{foreach $houses as $h}
			<li {if $house->id == $h->id}class="selected"{/if}>
				{if $h->parent_id == 0}
					{$h->name}
				{else}
					<a href="{url house_id=$h->id}">{$h->name}</a>
				{/if}
			</li>
			{if $h->subcategories}
				{houses_tree houses=$h->subcategories}
			{/if}
		{/foreach}
	</ul>
	{/if}
	{/function}
	{houses_tree houses=$houses}
		
</div>
<!-- Меню  (The End) -->


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
		$('#list input[type="checkbox"][name*="check"]').attr('checked', 1-$('#list input[type="checkbox"][name*="check"]').attr('checked'));
	});	

	// Удалить 
	$("a.delete").click(function() {
		$('#list input[type="checkbox"][name*="check"]').attr('checked', false);
		$(this).closest(".row").find('input[type="checkbox"][name*="check"]').attr('checked', true);
		$(this).closest("form").find('select[name="action"] option[value=delete]').attr('selected', true);
		$(this).closest("form").submit();
	});
	
	// Скрыт/Видим
	$("a.enable").click(function() {
		var icon        = $(this);
		var line        = icon.closest(".row");
		var id          = line.find('input[type="checkbox"][name*="check"]').val();
		var state       = line.hasClass('invisible')?1:0;
		icon.addClass('loading_icon');
		$.ajax({
			type: 'POST',
			url: 'ajax/update_object.php',
			data: {'object': 'issue', 'id': id, 'values': {'visible': state}, 'session_id': '{/literal}{$smarty.session.id}{literal}'},
			success: function(data){
				icon.removeClass('loading_icon');
				if(state)
					line.removeClass('invisible');
				else
					line.addClass('invisible');				
			},
			dataType: 'json'
		});	
		return false;	
	});
	
	// Подтверждение удаления
	$("form").submit(function() {
		if($('#list input[type="checkbox"][name*="check"]:checked').length>0)
			if($('select[name="action"]').val()=='delete' && !confirm('Подтвердите удаление'))
				return false;	
	});
});

</script>
{/literal}
