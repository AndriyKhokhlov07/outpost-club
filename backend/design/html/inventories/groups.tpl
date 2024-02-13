{* Вкладки *}
{capture name=tabs}
	<li>
		<a href="index.php?module=InventoriesHousesAdmin&type=1">Restocking</a>
		{if $new_restokings[1]}
			<div class='counter'>{$new_restokings[1]['count']}</div>
		{/if}
	</li>
	<li>
		<a href="index.php?module=InventoriesHousesAdmin&type=2">Kitchen restocking</a>
		{if $new_restokings[2]}
			<div class='counter'>{$new_restokings[2]['count']}</div>
		{/if}
	</li>
	<li class="active"><a href="index.php?module=InventoriesGroupsAdmin">Groups</a></li>
	<li><a href="index.php?module=InventoriesItemsAdmin">Items</a></li>
{/capture}

{* Title *}
{$meta_title='Groups' scope=parent}

{* Заголовок *}
<div id="header">
	<h1>Groups</h1>
	<a class="add" href="{url module=InventoriesGroupAdmin return=$smarty.server.REQUEST_URI}">Add new group</a>
</div>	
<!-- Заголовок (The End) -->

{if $groups}
<div id="main_list">

	<form id="list_form" method="post">
	<input type="hidden" name="session_id" value="{$smarty.session.id}">
		
		{function name=groups_tree level=0}
		{if $groups}
		<div id="list" class="sortable">
		
			{foreach $groups as $group}
			<div class="{if !$group->visible}invisible{/if} row">		
				<div class="tree_row">
					<input type="hidden" name="positions[{$group->id}]" value="{$group->position}">
					<div class="move cell" style="margin-left:{$level*20}px"><div class="move_zone"></div></div>
			 		<div class="checkbox cell">
						<input type="checkbox" name="check[]" value="{$group->id}" />				
					</div>
					<div class="cell">
						<a href="{url module=InventoriesGroupAdmin id=$group->id return=$smarty.server.REQUEST_URI}">{$group->name|escape}</a>
						<div class="sm">{if $group->type==1}Restocking{elseif $group->type==2}Kitchen restocking{/if}</div>		
					</div>
					<div class="icons cell">				
						<a class="enable" title="Enabled" href="#"></a>
						<a class="delete" title="Delete" href="#"></a>
					</div>
					<div class="clear"></div>
				</div>
				{groups_tree groups=$group->subcategories level=$level+1}
			</div>
			{/foreach}
	
		</div>
		{/if}
		{/function}
		{groups_tree groups=$groups}
		
		<div id="action">
		<label id="check_all" class="dash_link">Select all</label>
		
		<span id="select">
		<select name="action">
			<option value="enable">Enable</option>
			<option value="disable">Disable</option>
			<option value="delete">Delete</option>
		</select>
		</span>
		
		<input id="apply_action" class="button_green" type="submit" value="Apply">
		
		</div>
	
	</form>
</div>
{else}
No groups
{/if}

<div id="right_menu" class="v2">
	
	<ul>
		<li {if !$type}class="selected"{/if}><a href="{url type=null}">All types</a></li>
		<li {if $type==1}class="selected"{/if}>
			<a href="index.php?module=InventoriesGroupsAdmin&type=1">Restocking</a>
		</li>
		<li {if $type==2}class="selected"{/if}>
			<a href="index.php?module=InventoriesGroupsAdmin&type=2">Kitchen restocking</a>
		</li>
	</ul>

</div>


{literal}
<script>
$(function() {

	// Сортировка списка
	$(".sortable").sortable({
		items:".row",
		handle: ".move_zone",
		tolerance:"pointer",
		scrollSensitivity:40,
		opacity:0.7, 
		axis: "y",
		update:function()
		{
			$("#list_form input[name*='check']").attr('checked', false);
			$("#list_form").ajaxSubmit();
		}
	});
 
	// Выделить все
	$("#check_all").click(function() {
		$('#list input[type="checkbox"][name*="check"]:not(:disabled)').attr('checked', $('#list input[type="checkbox"][name*="check"]:not(:disabled):not(:checked)').length>0);
	});	

	// Показать категорию
	$("a.enable").click(function() {
		var icon        = $(this);
		var line        = icon.closest(".row");
		var id          = line.find('input[type="checkbox"][name*="check"]').val();
		var state       = line.hasClass('invisible')?1:0;
		icon.addClass('loading_icon');
		$.ajax({
			type: 'POST',
			url: 'ajax/update_object.php',
			data: {'object': 'inventories_group', 'id': id, 'values': {'visible': state}, 'session_id': '{/literal}{$smarty.session.id}{literal}'},
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

	// Delete 
	$("a.delete").click(function() {
		$('#list input[type="checkbox"][name*="check"]').attr('checked', false);
		$(this).closest("div.row").find('input[type="checkbox"][name*="check"]:first').attr('checked', true);
		$(this).closest("form").find('select[name="action"] option[value=delete]').attr('selected', true);
		$(this).closest("form").submit();
	});

	
	// Подтвердить удаление
	$("form").submit(function() {
		if($('select[name="action"]').val()=='delete' && !confirm('Please, confirm deletion'))
			return false;	
	});

});
</script>
{/literal}