{* Вкладки *}
{capture name=tabs}
	<li><a href="index.php?module=BlogAdmin&type=1">Blog</a></li>
	<!-- <li {if $type==2} class="active" {/if}><a href="index.php?module=BlogAdmin&type=2">Reviews</a></li> -->
	<li><a href="index.php?module=AuthorsAdmin">Authors</a></li>
	<li class="active"><a href="index.php?module=BlogTagsAdmin">Tags</a></li>
{/capture}

{* Title *}
{$meta_title='Tags' scope=parent}

{* Заголовок *}
<div id="header">
	<h1>Tags</h1>
	<a class="add" href="{url module=BlogTagAdmin return=$smarty.server.REQUEST_URI}">Add tag</a>
</div>	
<!-- Заголовок (The End) -->

{if $tags}
<div id="main_list" class="categories">

	<form id="list_form" method="post">
	<input type="hidden" name="session_id" value="{$smarty.session.id}">
		
		<div id="list" class="sortable">
		
			{foreach $tags as $tag}
			<div class="{if !$tag->visible}invisible {/if}{if $tag->featured}featured {/if}{if $tag->in_filter}in_filter {/if} row">		
				<div class="tree_row">
					<input type="hidden" name="positions[{$tag->id}]" value="{$tag->position}">
					<div class="move cell" style="margin-left:{$level*20}px"><div class="move_zone"></div></div>
			 		<div class="checkbox cell">
						<input type="checkbox" name="check[]" value="{$tag->id}" />				
					</div>
					<div class="cell">
						<a href="{url module=BlogTagAdmin id=$tag->id content_id=$tag->content_id language_id=$tag->language_id return=$smarty.server.REQUEST_URI}">{if $tag->name}{$tag->name|escape}{else}[Unnamed tag]{/if}</a> 	 			
					</div>
					<div class="icons cell">
						{* <a class="preview" title="Предпросмотр в новом окне" href="../catalog/{$tag->url}" target="_blank"></a>	*}	
						<a class="featured" title="" href="#"></a>
						<!-- <a title="Использовать в фильтре" class="in_filter" href='#' ></a>		 -->
						<a class="enable" title="Active" href="#"></a>
						<a class="delete" title="Delete" href="#"></a>
					</div>
					<div class="clear"></div>
				</div>
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
	Нет тегов
{/if}

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

	// Показать / Скрыть
	$("a.enable").click(function() {
		var icon        = $(this);
		var line        = icon.closest(".row");
		var id          = line.find('input[type="checkbox"][name*="check"]').val();
		var state       = line.hasClass('invisible')?1:0;
		icon.addClass('loading_icon');
		$.ajax({
			type: 'POST',
			url: 'ajax/update_object.php',
			data: {'object': 'blog_tag', 'id': id, 'values': {'visible': state}, 'session_id': '{/literal}{$smarty.session.id}{literal}'},
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

	// Указать "в фильтре"/"не в фильтре"
	$("a.in_filter").click(function() {
		var icon        = $(this);
		var line        = icon.closest(".row");
		var id          = line.find('input[type="checkbox"][name*="check"]').val();
		var state       = line.hasClass('in_filter')?0:1;
		icon.addClass('loading_icon');
		$.ajax({
			type: 'POST',
			url: 'ajax/update_object.php',
			data: {'object': 'blog_tag', 'id': id, 'values': {'in_filter': state}, 'session_id': '{/literal}{$smarty.session.id}{literal}'},
			success: function(data){
				icon.removeClass('loading_icon');
				if(!state)
					line.removeClass('in_filter');
				else
					line.addClass('in_filter');				
			},
			dataType: 'json'
		});	
		return false;	
	});

	// Сделать хитом
	$("a.featured").click(function() {
		var icon        = $(this);
		var line        = icon.closest("div.row");
		var id          = line.find('input[type="checkbox"][name*="check"]').val();
		var state       = line.hasClass('featured')?0:1;
		icon.addClass('loading_icon');
		$.ajax({
			type: 'POST',
			url: 'ajax/update_object.php',
			data: {'object': 'blog_tag', 'id': id, 'values': {'featured': state}, 'session_id': '{/literal}{$smarty.session.id}{literal}'},
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

	// Удалить 
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