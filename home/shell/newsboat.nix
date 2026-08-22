{ pkgs, ... }:
{
  programs.newsboat = {
    enable = true;
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
