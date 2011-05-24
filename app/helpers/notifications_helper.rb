module NotificationsHelper
  def object_link(note)
    target_type = note.popup_translation_key
    if note.instance_of?(Notifications::Mentioned)
      post = Mention.find(note.target_id).post
      if post
        "#{translation(target_type)} #{link_to t('notifications.post'), object_path(post)}".html_safe
      else
        "#{translation(target_type)} #{t('notifications.deleted')} #{t('notifications.post')}"
      end
    elsif note.instance_of?(Notifications::CommentOnPost)
      post = Post.where(:id => note.target_id).first
      if post
        "#{translation(target_type)} #{link_to t('notifications.post'), object_path(post), 'data-ref' => post.id, :class => 'hard_object_link'}".html_safe
      else
        "#{translation(target_type)} #{t('notifications.deleted')} #{t('notifications.post')}"
      end
    elsif note.instance_of?(Notifications::AlsoCommented)
      post = Post.where(:id => note.target_id).first
      if post
        "#{translation(target_type, post.author.name)} #{link_to t('notifications.post'), object_path(post), 'data-ref' => post.id, :class => 'hard_object_link'}".html_safe
      else
        t('notifications.also_commented_deleted')
      end
    elsif note.instance_of?(Notifications::Liked)
      post = note.target
      post = post.post if post.is_a? Like
      if post
        "#{translation(target_type, post.author.name)} #{link_to t('notifications.post'), object_path(post), 'data-ref' => post.id, :class => 'hard_object_link'}".html_safe
      else
        t('notifications.liked_post_deleted')
      end
    else #Notifications:StartedSharing, etc.
      translation(target_type)
    end
  end

  def translation(target_type, post_author = nil)
    t("#{target_type}", :post_author => post_author)
  end


  def new_notification_link(count)
    if count > 0
        link_to new_notification_text(count), notifications_path
    end
  end

  def notification_people_link(note)
    actors = note.actors
    number_of_actors = actors.count
    sentence_translations = {:two_words_connector => " #{t('notifications.index.and')} ", :last_word_connector => ", #{t('notifications.index.and')} " }
    actor_links = actors.collect{ |person| link_to("#{h(person.name.titlecase.strip)}", person_path(person))}
    
    if number_of_actors < 4
      message = actor_links.to_sentence(sentence_translations)
    else
      first, second, third, *others = actor_links
      others_sentence = others.to_sentence(sentence_translations)
      if others.count == 1
        others_sentence = " #{t('notifications.index.and')} " + others_sentence
      end
      message = "#{first}, #{second}, #{third},"
      message += "<a class='more' href='#'> #{t('notifications.index.and_others', :number =>(number_of_actors - 3))}</a>"
      message += "<span class='hidden'> #{others_sentence} </span>"
    end
    message.html_safe
  end

  def peoples_names(note)
    note.actors.map{|p| p.name}.join(", ")
  end

  def the_day(i18n)
    i18n[0].match(/\d/) ? i18n[0].gsub('.', '') : i18n[1].gsub('.', '')
  end

  def the_month(i18n)
    i18n[0].match(/\d/) ? i18n[1] : i18n[0]
  end
end
