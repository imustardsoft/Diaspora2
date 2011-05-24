/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */


(function() {
  var Embedder = function() { };
  Embedder.prototype.services = {};
  Embedder.prototype.register = function(service, template) {
    this.services[service] = template;
  };

  Embedder.prototype.render = function(service, views) {
    var template = (typeof this.services[service] === "string")
        ? this.services[service]
        : this.services.undefined;

    return $.mustache(template, views);
  };


  Embedder.prototype.embed = function($this) {
    var service = $this.data("host"),
      container = document.createElement("div"),
      $container = $(container).attr("class", "video-container"),
      $videoContainer = $this.closest('.content').children(".video-container");

    if($videoContainer.length) {
      $videoContainer.slideUp("fast", function() { $(this).detach(); });
      return;
    }

    if ($("div.video-container").length) {
      $("div.video-container").slideUp("fast", function() { $(this).detach(); });
    }

    $container.html(
        this.render(service, $this.data())
    );

    $container.hide()
     .insertAfter($this.parent())
     .slideDown('fast');


    $this.click(function() {
      $container.slideUp('fast', function() {
        $(this).detach();
      });
    });
  };

  Embedder.prototype.start = function() {
    $("#main_stream a.video-link").live("click", this.onVideoLinkClicked);
    this.registerServices();

    var $post = $("#main_stream").children(".stream_element:first"),
      $contentParagraph = $post.children(".sm_body").children('.content').children("p");

    this.canEmbed = $contentParagraph.length;
  };

  Embedder.prototype.registerServices = function() {
    var watchVideoOn = Diaspora.widgets.i18n.t("videos.watch");

    this.register("youtube.com",
        '<a href="//www.youtube.com/watch?v={{video-id}}{{anchor}}" target="_blank">' + $.mustache(watchVideoOn, { provider: "YouTube" }) + '</a><br />' +
        '<iframe class="youtube-player" type="text/html" src="http://www.youtube.com/embed/{{video-id}}?wmode=opaque{{anchor}}"></iframe>');

    this.register("vimeo.com",
      '<a href="http://vimeo.com/{{video-id}}">' + $.mustache(watchVideoOn, { provider: "Vimeo" }) + '</a><br />' +
      '<iframe class="vimeo-player" src="http://player.vimeo.com/video/{{video-id}}"></iframe>');

    this.register("undefined", '<p>' + Diaspora.widgets.i18n.t("videos.unknown") + ' - {{host}}</p>');
  };

  Embedder.prototype.onVideoLinkClicked = function(evt) {
    if(Diaspora.widgets.embedder.canEmbed) {
      evt.preventDefault();
      Diaspora.widgets.embedder.embed($(this));
    }
  };

  Diaspora.widgets.add("embedder", Embedder);
})();
