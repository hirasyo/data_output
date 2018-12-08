class PagesController < ApplicationController
  def index
  end

  def get
    @outstr_pokemon = ""
    @outstr_terry = ""

    # 各種サイトのチェックに応じてデータを持ってくる
    if params["pokemon"]
      # ぽけGOのURLからhtml情報を抽出
      @html,@charset = search_html(url_pokemon)
      # 抽出したhtmlをパース(解析)してオブジェクトを作成
      @result_pokemon = Nokogiri::HTML.parse(@html, nil, @charset)
      # 解析オブジェクトから必要な情報を抽出
      get_info_pokemon(@result_pokemon)
      # ファイルを作成
      f = File.open('./app/assets/pokemon.txt', 'w')
      f.puts @outstr_pokemon
      f.close

    end

    if params["terry"]
      # テリワンのURLからhtml情報を抽出
      @html,@charset = search_html(url_terry)
      # 抽出したhtmlをパース(解析)してオブジェクトを作成
      @result_terry = Nokogiri::HTML.parse(@html, nil, @charset)
      # 解析オブジェクトから必要な情報を抽出
      get_info_terry(@result_terry)
      # ファイルを作成
      f = File.open('./app/assets/terry.txt', 'w')
      f.puts @outstr_terry
      f.close

    end

  end

  private

    def url_pokemon
      "https://appmedia.jp/pokemon_go/385989"
    end

    def url_terry
      "https://altema.jp/terrysp/haigouhyou"
    end

    def search_html(url)
      charset = nil
      search_url = URI.encode url
      html = open(search_url) do |f|
        charset = f.charset # 文字種別を取得
        f.read # htmlを読み込んで変数htmlに渡す
      end
      return html,charset
    end

    def get_info_pokemon(result)
      @outstr_pokemon = "ポケモン名　通常わざ：ゲージわざ　　"
      result.xpath('//div[@class="post-content"]/table[1]/tbody').each do |node|
        @outstr_pokemon = @outstr_pokemon + "\n\n" + node.xpath('tr/td[1]/a').inner_text + "　" + node.xpath('tr[1]/td[3]/a').inner_text + "：" + node.xpath('tr[1]/td[4]/a').inner_text
      end
    end

    def get_info_terry(result)
      @outstr_terry = "配合先:（素材１＋素材２）　　"
      for i in 3..12 do
        for j in 1..100 do
          result.xpath("//div[1]/div[2]/div[1]/table[#{i}]/tbody/tr[#{j}]").each do |node|
            if node.css('a.mokujimusibtn').present? || node.css('a/span/img').present?
              @outstr_terry.chop!.chop!
              @outstr_terry = @outstr_terry + "\n\n" + "！" + node.xpath('td[1]/a/span').inner_text + "！:" + "\n"
              if node.xpath('td[2]/a[2]').present?
                @outstr_terry = @outstr_terry + "（" + node.xpath('td[2]/a[1]').inner_text + "＋" + node.xpath('td[2]/a[2]').inner_text + "）or"
              else
                if node.xpath('td[2]').present?
                  @outstr_terry = @outstr_terry + "（" + node.xpath('td[2]').inner_text.gsub(/\s/,"＋") + "）or"
                else
                  @outstr_terry = @outstr_terry + "（" + node.xpath('td').inner_text.gsub(/\s/,"＋") + "）or"
                end
              end
            elsif
              @outstr_terry = @outstr_terry + "（" + node.xpath('td/a[1]').inner_text + "＋" + node.xpath('td/a[2]').inner_text + "）or"
            end

          end

        end
      end

      @outstr_terry.gsub(/（＋）/,"")

    end

end
