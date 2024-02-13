{* Вкладки *}
{capture name=tabs}
	<li class="active"><a href="?module=GalleriesAdmin">Galleries</a></li>
{/capture}

{* Title *}
{$meta_title = {$menu->name} scope=parent}

{if $category->id}
	{$meta_title = $category->name scope=parent}
{else}
	{$meta_title = 'Galleries' scope=parent}
{/if}

{* Заголовок *}
<div id="header">
	<h1>
    {if $category->id}
        {$category->name}
    {else}
        Galleries
    {/if}
    </h1>
	<a class="add" href="{url module=GalleryAdmin}">Add a gallery</a>
</div>

{if $galleries}
<div id="main_list">
 
	<form id="list_form" method="post">
		<input type="hidden" name="session_id" value="{$smarty.session.id}">
		<div id="list" class="sortable">		
			{foreach $galleries as $gallery}
			<div class="{if !$gallery->visible}invisible{/if} row">
				<input type="hidden" name="positions[{$gallery->id}]" value="{$gallery->position}">
				<div class="move cell"><div class="move_zone"></div></div>
		 		<div class="checkbox cell">
					<input type="checkbox" name="check[]" value="{$gallery->id}" />				
				</div>
				<div class="name cell">
					<a href="{url module=GalleryAdmin id=$gallery->id return=$smarty.server.REQUEST_URI}">{$gallery->name|escape}</a>
				</div>
				<div class="icons cell">
					<a class="preview" title="Preview in new window" href="../{$page->url}" target="_blank"></a>
					<a class="enable" title="Published" href="#"></a>
					<a class="delete" title="Delete" href="#"></a>
				</div>
				<div class="clear"></div>
			</div>
			{/foreach}
		</div>
	
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
	No galleries
{/if}

 <!-- Меню -->
<div id="right_menu">
	
	<!-- Категории галерей -->
	{function name=categories_tree}
	{if $categories}
	<ul>
		{if $categories[0]->parent_id == 0}
		<li {if !$category->id}class="selected"{/if}><a href="{url category_id=null}">All categories</a></li>	
		{/if}
		{foreach $categories as $c}
		<li category_id="{$c->id}" {if $category->id == $c->id}class="selected"{else}class="droppable category"{/if}><a href='{url page=null category_id={$c->id}}'>{$c->name}</a></li>
		{categories_tree categories=$c->subcategories}
		{/foreach}
	</ul>
	{/if}
	{/function}
	{categories_tree categories=$categories}
	<!-- Категории галерей (The End)-->
		
</div>
<!-- Левое меню  (The End) -->

{* On document load *}
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

 
	// Раскраска строк
	function colorize()
	{
		$(".row:even").addClass('even');
		$(".row:odd").removeClass('even');
	}
	// Раскрасить строки сразу
	colorize();
 

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
			data: {'object': 'gallery', 'id': id, 'values': {'visible': state}, 'session_id': '{/literal}{$smarty.session.id}{literal}'},
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
