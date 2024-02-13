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

	<li><a href="index.php?module=InventoriesGroupsAdmin">Groups</a></li>
	<li class="active"><a href="index.php?module=InventoriesItemsAdmin">Items</a></li>
{/capture}

{* Title *}
{$meta_title='Items' scope=parent}

{* Заголовок *}
<div id="header">
	<h1>Items</h1> 
	<a class="add" href="{url module=InventoriesItemAdmin return=$smarty.server.REQUEST_URI}">Add new item</a>
</div>	

{if $items}
<div id="main_list" class="items">
	
	<form id="list_form" method="post">
	<input type="hidden" name="session_id" value="{$smarty.session.id}">

		<div id="list">
			{foreach $items as $item}
			<div class="{if !$item->visible}invisible{/if} row">
				<input type="hidden" name="positions[{$item->id}]" value="{$item->position}">
				<div class="move cell"><div class="move_zone"></div></div>
		 		<div class="checkbox cell">
					<input type="checkbox" name="check[]" value="{$item->id}" />				
				</div>
				<div class="cell">
					<a href="{url module=InventoriesItemAdmin id=$item->id return=$smarty.server.REQUEST_URI}">{$item->name|escape}</a>
				</div>
				<div class="icons cell">
					<a class="enable" title="Enabled" href="#"></a>
					<a class="delete" title="Delete" href='#' ></a>
				</div>
				<div class="clear"></div>
			</div>
			{/foreach}
		</div>
		
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
	No items
{/if}
 
 <!-- Меню -->
<div id="right_menu" class="v2">

	<ul>
		<li {if !$type}class="selected"{/if}><a href="{url type=null}">All types</a></li>
		<li {if $type==1}class="selected"{/if}>
			<a href="{url type=1}">Restocking</a>
		</li>
		<li {if $type==2}class="selected"{/if}>
			<a href="{url type=2}">Kitchen restocking</a>
		</li>
	</ul>
	

	{function name=groups_tree}
	{if $groups}
	<ul>
		{if $groups[0]->parent_id == 0}
			<li {if !$group->id}class="selected"{/if}><a href="{url group_id=null}">All groups</a></li>	
		{/if}
		{foreach $groups as $g}
			{if !$type || $type==$g->type}
				<li {if $group->id == $g->id}class="selected"{/if}>
					<a href="{url group_id=$g->id}">{$g->name}</a>
				</li>
				{if $g->subcategories}
					{groups_tree groups=$g->subcategories}
				{/if}
			{/if}
		{/foreach}
	</ul>
	{/if}
	{/function}
	{groups_tree groups=$groups}


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
	
	// Сортировка списка
	$("#list").sortable({
		items:             ".row",
		tolerance:         "pointer",
		handle:            ".move_zone",
		axis: 'y',
		scrollSensitivity: 40,
		opacity:           0.7, 
		forcePlaceholderSize: true,
		
		helper: function(event, ui){		
			if($('input[type="checkbox"][name*="check"]:checked').size()<1) return ui;
			var helper = $('<div/>');
			$('input[type="checkbox"][name*="check"]:checked').each(function(){
				var item = $(this).closest('.row');
				helper.height(helper.height()+item.innerHeight());
				if(item[0]!=ui[0]) {
					helper.append(item.clone());
					$(this).closest('.row').remove();
				}
				else {
					helper.append(ui.clone());
					item.find('input[type="checkbox"][name*="check"]').attr('checked', false);
				}
			});
			return helper;			
		},	
 		start: function(event, ui) {
  			if(ui.helper.children('.row').size()>0)
				$('.ui-sortable-placeholder').height(ui.helper.height());
		},
		beforeStop:function(event, ui){
			if(ui.helper.children('.row').size()>0){
				ui.helper.children('.row').each(function(){
					$(this).insertBefore(ui.item);
				});
				ui.item.remove();
			}
		},
		update:function(event, ui)
		{
			$("#list_form input[name*='check']").attr('checked', false);
			$("#list_form").ajaxSubmit(function() {
				colorize();
			});
		}
	});
	
	// Выделить все
	$("#check_all").click(function() {
		$('#list input[type="checkbox"][name*="check"]').attr('checked', $('#list input[type="checkbox"][name*="check"]:not(:checked)').length>0);
	});	
	
	// Активный / Неактивный
	$("a.enable").click(function() {
		var icon        = $(this);
		var line        = icon.closest(".row");
		var id          = line.find('input[type="checkbox"][name*="check"]').val();
		var state       = line.hasClass('invisible')?1:0;
		icon.addClass('loading_icon');
		$.ajax({
			type: 'POST',
			url: 'ajax/update_object.php',
			data: {'object': 'inventories_item', 'id': id, 'values': {'visible': state}, 'session_id': '{/literal}{$smarty.session.id}{literal}'},
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
		$(this).closest("div.row").find('input[type="checkbox"][name*="check"]').attr('checked', true);
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