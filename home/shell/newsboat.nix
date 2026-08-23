{ pkgs, ... }:
{
  programs.newsboat = {
    enable = true;
    extraConfig = "
       color title default black 
       color info default black
       color hint-key white black
       bind k article,help up
       bind j article,help down
    ";
    urls = [
      {
        tags = [
          "technology"
          "computing"
          "ai"
        ];
        url = "https://spectrum.ieee.org/customfeeds/feed/all-topics/rss";
      }
      {
        tags = [
          "space"
          "science"
        ];
        url = "https://www.newscientist.com/subject/space/feed/";
      }
      {
        tags = [
          "physics"
          "science"
        ];
        url = "https://www.newscientist.com/subject/physics/feed/";
      }
    ];
  };
}
