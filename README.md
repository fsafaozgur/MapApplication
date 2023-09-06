
# MapApplication Uygulaması

## Giriş
Proje kapsamında; MapKit kütühanesi kullanılarak, haritadan seçilen bir konumun kaydedildiği ve önceden kaydedilen konumların seçilerek Navigasyon uygulaması ile yol tarifi alınabildiği bir uygulama tasarlanmıştır. 

## Hedef
Proje ile birlikte; MapKit kütüphanesi kullanılarak haritadan tıklanarak bir konum seçilmesi ve bu konuma ait bilgilerin CoreData ile kaydedilmesi, kaydedilen konuma ait bilgilerin kullanıcıya bir arayüz yardımı ile sunulması ile bu konuma yol tarifi alınması işlemlerinin nasıl tasarlanacağının ortaya konulması amaçlanmıştır. 

## Uygulama Kullanımı
Uygulama ilk olarak kullanıcının konum ve konuma ilişkin bilgileri girmesi ve bunların CoreData yardımıyla yerel veritabanına kaydedilmesi ile başlamaktadır.

Kaydedilen konumlara verilen isimler bir arayüz yardımı ile kullanıcıya listelenmekte ve böylece önceden kaydedilen konumlar ve bunlara ilişkin detaylara kullanıcı tarafından sonradan da ulaşılabilmektedir

Listeden seçilen konuma ilişkin bilgilerin gösterildiği ekranda, harita üzerinde gösterilen konuma tıklanarak, tıklandığından görülen bir tuş yardımıyla Navigasyon uygulamasına gidilebilmekte ve seçilen konuma yol tarifi alınabilmektedir.
