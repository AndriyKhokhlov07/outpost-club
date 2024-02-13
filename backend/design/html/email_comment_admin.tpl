{if $comment->approved}
{$subject="New comment from `$comment->name|escape`" scope=parent}
{else}
{$subject="Comment from `$comment->name|escape` is awaiting approval" scope=parent}
{/if}
{if $comment->approved}
<h1 style="font-weight:normal;font-family:arial;"><a href="{$config->root_url}/backend/index.php?module=CommentsAdmin">New comment</a> from {$comment->name|escape}</h1>
{else}
<h1 style="font-weight:normal;font-family:arial;"><a href="{$config->root_url}/backend/index.php?module=CommentsAdmin">Comment</a> from {$comment->name|escape} is awaiting approval</h1>
{/if}

<table cellpadding="6" cellspacing="0" style="border-collapse: collapse;">
  <tr>
    <td style="padding:6px; width:170; background-color:#f0f0f0; border:1px solid #e0e0e0;font-family:arial;">
      Name
    </td>
    <td style="padding:6px; width:330; background-color:#ffffff; border:1px solid #e0e0e0;font-family:arial;">
      {$comment->name|escape}
    </td>
  </tr>
  <tr>
    <td style="padding:6px; background-color:#f0f0f0; border:1px solid #e0e0e0;font-family:arial;">
      Comment
    </td>
    <td style="padding:6px; background-color:#ffffff; border:1px solid #e0e0e0;font-family:arial;">
      {$comment->text|escape|nl2br}
    </td>
  </tr>
  <tr>
    <td style="padding:6px; background-color:#f0f0f0; border:1px solid #e0e0e0;font-family:arial;">
      Time
    </td>
    <td style="padding:6px; width:170; background-color:#ffffff; border:1px solid #e0e0e0;font-family:arial;">
      {$comment->date|date} {$comment->date|time}
    </td>
  </tr>
  <tr>
    <td style="padding:6px; width:170; background-color:#f0f0f0; border:1px solid #e0e0e0;font-family:arial;">
      Status
    </td>
    <td style="padding:6px; width:330; background-color:#ffffff; border:1px solid #e0e0e0;font-family:arial;">
      {if $comment->approved}
        Approved    
      {else}
        Awaiting approval
      {/if}
    </td>
  </tr>
<tr>
  <td style='padding:6px; background-color:#f0f0f0; border:1px solid #e0e0e0;font-family:arial;'>
    IP
  </td>
  <td style='padding:6px; width:170; background-color:#ffffff; border:1px solid #e0e0e0;font-family:arial;'>
    {$comment->ip|escape} (<a href='http://www.ip-adress.com/ip_tracer/{$comment->ip}/'>где это?</a>)
  </td>
  </tr>
  <tr>
    <td style="padding:6px; width:170; background-color:#f0f0f0; border:1px solid #e0e0e0;font-family:arial;">
      {if $comment->type == 'product'}К товару{/if}
      {if $comment->type == 'blog'}К записи{/if}
    </td>
    <td style="padding:6px; width:330; background-color:#ffffff; border:1px solid #e0e0e0;font-family:arial;">
      {if $comment->type == 'product'}<a target="_blank" href="{$config->root_url}/products/{$comment->product->url}#comment_{$comment->id}">{$comment->product->name}</a>{/if}
      {if $comment->type == 'blog'}<a target="_blank" href="{$config->root_url}/blog/{$comment->post->url}#comment_{$comment->id}">{$comment->post->name}</a>{/if}
    </td>
  </tr>
</table>
<br><br>
Enjoy your work with <a href='http://simp.la'>Backend</a>!