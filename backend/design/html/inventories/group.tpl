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

{if $group->id}
{$meta_title = $group->name scope=parent}
{else}
{$meta_title = 'New group' scope=parent}
{/if}

{* Подключаем Tiny MCE *}
{include file='tinymce_init.tpl'}



{if $message_success}
<!-- Системное сообщение -->
<div class="message message_success">
	<span class="text">{if $message_success=='added'}{$group->name|escape} was created{elseif $message_success=='updated'}{$group->name|escape} was updated{else}{$message_success}{/if}</span>
	{if $smarty.get.return}
	<a class="button" href="{$smarty.get.return}">Back</a>
	{/if}
</div>
<!-- Системное сообщение (The End)-->
{/if}

{if $message_error}
<!-- Системное сообщение -->
<div class="message message_error">
	<span class="text">{$message_error}</span>
	<a class="button" href="">Back</a>
</div>
<!-- Системное сообщение (The End)-->
{/if}


<!-- Основная форма -->
<form method=post id=product enctype="multipart/form-data">
<input type=hidden name="session_id" value="{$smarty.session.id}">
	<div id="name">
		<input class="name" name=name type="text" value="{$group->name|escape}"/> 
		<input name=id type="hidden" value="{$group->id|escape}"/> 
		<div class="checkbox">
			<input name=visible value='1' type="checkbox" id="active_checkbox" {if $group->visible}checked{/if}/> <label for="active_checkbox">Enabled</label>
		</div>
	</div> 
		
	<div id="column_left">
		
		<div class="block layer">
			<ul>

				<li>
					<label class=property>Parent</label>
					<select name="parent_id">
						<option value='0'>Root group</option>
						{function name=group_select level=0}
						{foreach $cats as $cat}
							{if $group->id != $cat->id}
								<option value='{$cat->id}' {if $group->parent_id == $cat->id}selected{/if}>{section name=sp loop=$level}&nbsp;&nbsp;&nbsp;&nbsp;{/section}{$cat->name} ({if $cat->type==1}Restocking{elseif $cat->type==2}Kitchen restocking{/if})</option>
								{group_select cats=$cat->subcategories level=$level+1}
							{/if}
						{/foreach}
						{/function}
						{group_select cats=$groups}
					</select>
				</li>

				<li>
					<label class=property>Type</label>
					<select name="type">
						<option value='1' {if $group->type==1}selected{/if}>Restocking</option>
						<option value='2' {if $group->type==2}selected{/if}>Kitchen restocking</option>
					</select>
				</li>

			</ul>
		</div>
			
	</div>
	

	<!-- Описагние категории -->
	<div class="block layer">
		<h2>Description</h2>
		<textarea name="description" class="editor_small">{$group->description|escape}</textarea>
	</div>
	<!-- Category description категории (The End)-->
	<input class="button_green button_save" type="submit" name="" value="Save" />
	
</form>
<!-- Основная форма (The End) -->

