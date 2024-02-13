{* Title *}
{$meta_title='Authors' scope=parent}

{capture name=tabs}
	<li><a href="index.php?module=BlogAdmin&type=1">Blog</a></li>
	<!-- <li {if $type==2} class="active" {/if}><a href="index.php?module=BlogAdmin&type=2">Reviews</a></li> -->
	<li class="active"><a href="index.php?module=AuthorsAdmin">Authors</a></li>
	<li><a href="index.php?module=BlogTagsAdmin">Tags</a></li>
{/capture}
		
{* Заголовок *}
<div id="header">
	{if $keyword && $authors_count}
	<h1>Found {$authors_count} {$authors_count|plural:'author':'authors'}</h1>
	{elseif $authors_count}
	<h1>{$authors_count} {$authors_count|plural:'author':'authors'}</h1>
	{else}
	<h1>No authors</h1>
	{/if}
	<a class="add" href="{url module=AuthorAdmin return=$smarty.server.REQUEST_URI}">Add author</a>
</div>	

{if $authors}
<div id="main_list">
	{include file='pagination.tpl'}	
	<form id="list_form" method="post">
	<input type="hidden" name="session_id" value="{$smarty.session.id}">		
		<div id="list" class="sortable">
			{foreach $authors as $author}
			<div class="{if !$author->visible}invisible {/if}{if $author->featured}featured {/if}row">		
					<input type="hidden" name="positions[{$author->id}]" value="{$author->position}">
					<div class="move cell"><div class="move_zone"></div></div>
			 		<div class="checkbox cell">
						<input type="checkbox" name="check[]" value="{$author->id}" />				
					</div>
					<div class="image cell">
						{if $author->image}
						<a href="{url module=AuthorAdmin id=$author->id content_id=$author->content_id language_id=$author->language_id return=$smarty.server.REQUEST_URI}"><img src="{$author->image|resize:author:35:35}" /></a>
						{/if}
					</div>
					<div class="cell">
						<a href="{url module=AuthorAdmin id=$author->id content_id=$author->content_id language_id=$author->language_id return=$smarty.server.REQUEST_URI}">{$author->name|escape}</a>	 			
					</div>
					<div class="icons cell">
                        <!-- <a class="featured" title="Блогер" href="#"></a>	 -->
						<a class="enable" title="Active" href="#"></a>
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

		<span id="move_to_page">
			<select name="target_page">
				{section target_page $pages_count}
				<option value="{$smarty.section.target_page.index+1}">{$smarty.section.target_page.index+1}</option>
				{/section}
			</select> 
		</span>
		
		<input id="apply_action" class="button_green" type="submit" value="Apply">
		
		</div>
	</form>
	{include file='pagination.tpl'}	
</div>

{else}
	Нет записей
{/if}

<!-- Меню -->
<div id="right_menu">
	
	<!-- Фильтры -->
	<ul>
		<li {if !$filter}class="selected"{/if}><a href="{url page=null filter=null}">All</a></li>
		<li {if $filter=='visible'}class="selected"{/if}><a href="{url page=null filter='visible'}">Published</a></li>
		<li {if $filter=='hidden'}class="selected"{/if}><a href="{url page=null filter='hidden'}">Unpublished</a></li>
	</ul>
	<!-- Фильтры -->

</div>

{* On document load *}
{literal}
<script>
$(function() {

	$("a.featured").click(function() {
		var icon        = $(this);
		var line        = icon.closest("div.row");
		var id          = line.find('input[type="checkbox"][name*="check"]').val();
		var state       = line.hasClass('featured')?0:1;
		icon.addClass('loading_icon');
		$.ajax({
			type: 'POST',
			url: 'ajax/update_object.php',
			data: {'object': 'author', 'id': id, 'values': {'featured': state}, 'session_id': '{/literal}{$smarty.session.id}{literal}'},
			success: function(data){
				icon.removeClass('loading_icon');
				if(state)
					line.addClass('featured');				
				else
					line.removeClass('featured');
			},
			dataType: 'json'
		});	
		return false;	
	});

	// Сортировка списка
	$("#list").sortable({
		items:             ".row",
		tolerance:         "pointer",
		handle:            ".move_zone",
		scrollSensitivity: 40,
		opacity:           0.7, 
		
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

	// Перенос на другую страницу
	$("#action select[name=action]").change(function() {
		if($(this).val() == 'move_to_page')
			$("span#move_to_page").show();
		else
			$("span#move_to_page").hide();
	});
	$("#pagination a.droppable").droppable({
		activeClass: "drop_active",
		hoverClass: "drop_hover",
		tolerance: "pointer",
		drop: function(event, ui){
			$(ui.helper).find('input[type="checkbox"][name*="check"]').attr('checked', true);
			$(ui.draggable).closest("form").find('select[name="action"] option[value=move_to_page]').attr("selected", "selected");		
			$(ui.draggable).closest("form").find('select[name=target_page] option[value='+$(this).html()+']').attr("selected", "selected");
			$(ui.draggable).closest("form").submit();
			return false;	
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
			type: 'post',
			url: 'ajax/update_object.php',
			data: {'object': 'author', 'id': id, 'values': {'visible': state}, 'session_id': '{/literal}{$smarty.session.id}{literal}'},
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
