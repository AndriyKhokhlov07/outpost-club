{* Вкладки *}
{capture name=tabs}
	{if in_array($menu->id, array(12))}
		{if in_array('users', $manager->permissions)}
			<li><a href="index.php?module=UsersAdmin">Guests</a></li>
			<li><a href="index.php?module=MoveInAdmin">Move In</a></li>
			<li><a href="index.php?module=FarewellAdmin">Farewell</a></li>
		{/if}
		{if in_array('issues', $manager->permissions)}<li><a href="index.php?module=IssuesAdmin">Technical Issues</a></li>{/if}
		{if in_array('pages', $manager->permissions)}
			{foreach from=$menus item=m}
				{if in_array("menu_`$m->id`", $manager->permissions) && in_array($m->id, array(12))}
					<li {if $m->id == $menu->id}class="active"{/if}><a href='?module=PagesAdmin&menu_id={$m->id}'>{$m->name}</a></li>
				{/if}
			{/foreach}
		{/if}
	{else}

		{if in_array('pages', $manager->permissions)}
			{foreach from=$menus item=m}
				{if in_array("menu_`$m->id`", $manager->permissions) && !in_array($m->id, array(12))}
				<li {if $m->id == $menu->id}class="active"{/if}><a href="{url module=PagesAdmin menu_id=$m->id}">{$m->name}</a></li>
				{/if}
			{/foreach}
			<!-- <li><a href="{url module=LoansAdmin menu_id=null}"></a></li> -->
		{/if}
		
		{if in_array('galleries', $manager->permissions)}
			<li><a href="{url module=GalleriesAdmin}">Gallery</a></li>
		{/if}
	{/if}
{/capture}

{* Title *}
{$meta_title = {$menu->name} scope=parent}

{* Заголовок *}
<div id="header">
	<h1>{$menu->name}</h1>
	<a class="add" href="{url module=PageAdmin}">Add new page</a>
</div>

{if $pages}
<div id="main_list">
 
	<form id="list_form" method="post">
		<input type="hidden" name="session_id" value="{$smarty.session.id}">
		<!--<div id="list">	-->
        	{*	
			{foreach $pages as $page}
			<div class="{if !$page->visible}invisible{/if} row">
				<input type="hidden" name="positions[{$page->id}]" value="{$page->position}">
				<div class="move cell"><div class="move_zone"></div></div>
		 		<div class="checkbox cell">
					<input type="checkbox" name="check[]" value="{$page->id}" />				
				</div>
				<div class="name cell">
					<a href="{url module=PageAdmin id=$page->id return=$smarty.server.REQUEST_URI}">{$page->header|escape}</a>
				</div>
				<div class="icons cell">
					<a class="preview" title="Preview in new window" href="../{$page->url}" target="_blank"></a>
					<a class="enable" title="Published" href="#"></a>
					<a class="delete" title="Delete" href="#"></a>
				</div>
				<div class="clear"></div>
			</div>
			{/foreach}
            *}
            
            
            
            
            
            {function name=pages_tree level=0}
            {if $pages}
            <div id="list" class="sortable">
            
                {foreach $pages as $page}
                <div class="{if !$page->visible}invisible{/if} row">		
                    <div class="tree_row">
                        <input type="hidden" name="positions[{$page->id}]" value="{$page->position}">
                        <div class="move cell" style="margin-left:{$level*20}px"><div class="move_zone"></div></div>
                        <div class="checkbox cell">
                            <input type="checkbox" name="check[]" value="{$page->id}" />				
                        </div>
                        <div class="name cell">
                            <a href="{url module=PageAdmin id=$page->id return=$smarty.server.REQUEST_URI}">{$page->header|escape}</a>
                        </div>
                        <div class="icons cell">
                            <a class="preview" title="Preview in new window" href="../{$page->url}" target="_blank"></a>
					<a class="enable" title="Published" href="#"></a>
					<a class="delete" title="Delete" href="#"></a>
                        </div>
                        <div class="clear"></div>
                    </div>
                    {pages_tree pages=$page->subcategories level=$level+1}
                </div>
                {/foreach}
        
            </div>
            {/if}
            {/function}
            {pages_tree pages=$pages}
            
            
		<!--</div>-->
	
		<div id="action">
		<label id="check_all" class="dash_link">Select all</label>
	
		<span id="select">
		<select name="action">
			<option value="enable">Publish</option>
			<option value="disable">Unpublish</option>
			<option value="delete">Delete</option>
		</select>
		</span>
	
		<input id="apply_action" class="button_green" type="submit" value="Apply">
	
		</div>
	</form>	
</div>
{else}
	No pages
{/if}

{* On document load *}
{literal}
<script>
$(function() {

	// Сортировка списка
	$(".sortable").sortable({
		items:             ".row",
		tolerance:         "pointer",
		handle:            ".move_zone",
		scrollSensitivity: 40,
		opacity:           0.7, 
		//forcePlaceholderSize: true,
		axis: 'y',
		
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

/* 
	// Раскраска строк
	function colorize()
	{
		$(".row:even").addClass('even');
		$(".row:odd").removeClass('even');
	}
	// Раскрасить строки сразу
	colorize();
*/

	// Выделить все
	$("#check_all").click(function() {
		$('#list input[type="checkbox"][name*="check"]').attr('checked', $('#list input[type="checkbox"][name*="check"]:not(:checked)').length>0);
	});	

	// Удалить 
	$("a.delete").click(function() {
		$('#list_form input[type="checkbox"][name*="check"]').attr('checked', false);
		$(this).closest(".row").find('input[type="checkbox"][name*="check"]').attr('checked', true);
		$(this).closest("form").find('select[name="action"] option[value=delete]').attr('selected', true);
		$(this).closest("form").submit();
	});
	

	// Показать
	$("a.enable").click(function() {
		var icon        = $(this);
		var line        = icon.closest(".row");
		var id          = line.find('input[type="checkbox"][name*="check"]').val();
		var state       = line.hasClass('invisible')?1:0;
		icon.addClass('loading_icon');
		$.ajax({
			type: 'POST',
			url: 'ajax/update_object.php',
			data: {'object': 'page', 'id': id, 'values': {'visible': state}, 'session_id': '{/literal}{$smarty.session.id}{literal}'},
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


	$("form").submit(function() {
		if($('select[name="action"]').val()=='delete' && !confirm('Please, confirm deletion'))
			return false;	
	});
});
</script>
{/literal}
