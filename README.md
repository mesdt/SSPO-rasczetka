# Методичка по связям в Active Record в Ruby On Rails


## Введение

Работа веб-приложений тесно связана с базами данных: нужно сохранить свои записи в блоге, ваши комментарии к этим постам, логины зарегистированных на сайте пользователей и много чего другого, не счесть.

Писать SQL-запросы в коде страницы нынче не в моде, хотя некоторые староверы так до сих пор делают.
Ну а мы будем использовать ORM. Для примера я покажу работу ActiveRecord в Ruby On Rails.

>«ORM (англ. Object-relational mapping) — технология программирования, которая связывает базы данных с концепциями объектно-ориентированных языков программирования, создавая «виртуальную объектную базу данных»

Чтож, не будем тянуть и попробуем разобраться на примере.

## Ассоциации
В Ruby On Rails ассоциация(или связь) - это соединение двух моделей Active Record. 
Зачем нам нужны связи между моделями? Затем, что они позволяют сделать код для обычных операций проще и легче. 

Пока вы можете пропустить эту часть и перейти к разбору примера. Вы же всегда сможете вернуться :) 

Вообще видов связей в Active Record довольно много:
  * belongs_to
  * has_one
  * has_many
  * has_many :through
  * has_one :through
  * has_and_belongs_to_many

За самой подробной информацией, как всегда, нужно обращаться в документацию([русский](http://rusrails.ru/active-record-associations)), [английский](http://guides.rubyonrails.org/association_basics.html):

### belongs_to

Связь belongs_to устанавливает соединение "один-к-одному" с другой моделью,
когда один экземпляр объявляющей модели "принадлежит" одному экземпляру другой модели.

В терминах базы данных эта связь сообщает, что этот класс содержит внешний ключ. 
Если внешний ключ содержит другой класс, вместо этого следует использовать has_one.

В этой связи обязательно следует использовать единственное число.
Если использовать множественное число, то вам будет сообщено "uninitialized constant Таблица_1::Таблица_2".
 Это так, потому что Rails автоматически получает имя класса из имени связи. 

### has_one

Связь has_one также устанавливает соединение один-к-одному с другой моделью,
 но в несколько ином смысле (и с другими последствиями). 
Эта связь показывает, что каждый экземпляр модели содержит или обладает одним экземпляром другой модели.
В терминах базы данных эта связь сообщает, что другой класс содержит внешний ключ. Если этот класс содержит внешний ключ, следует использовать belongs_to.

### has_many

Связь has_many указывает на соединение "один-ко-многим" с другой моделью.
 Эта связь часто бывает на "другой стороне" связи belongs_to. 
Эта связь указывает на то, что каждый экземпляр модели имеет ноль или более экземпляров другой модели.

### has_many :through

Связь has_many :through часто используется для настройки соединения "многие-ко-многим" с другой моделью.
 Эта связь указывает, что объявляющая модель может соответствовать нулю или более экземплярам другой модели через третью модель.

### has_one :through

Связь has_one :through настраивает соединение "один-к-одному" с другой моделью.
Эта связь показывает, что объявляющая модель может быть связана с одним экземпляром другой модели через третью модель.

### has_and_belongs_to_many

Связь has_and_belongs_to_many создает прямое соединение "многие-ко-многим" с другой моделью, без промежуточной модели.

### belongs_to или has_one?

Если хотите настроить отношение "один-к-одному" между двумя моделями,
 необходимо добавить belongs_to к одной и has_one к другой. Как узнать что к какой?

Различие в том, где помещен внешний ключ (он должен быть в таблице для класса, 
объявляющего связь belongs_to), но вы также должны думать о реальном значении данных.
Отношение has_one говорит, что что-то принадлежит вам - то есть что что-то указывает на вас

### has_many :through или has_and_belongs_to_many?

Простейший способ - использовать has_and_belongs_to_many, который позволяет создать связь напрямую.

Второй способ объявить отношение "многие-ко-многим" - использование has_many :through.
 Это осуществляет связь не напрямую, а через соединяющую модель.
Простейший признак того, что нужно настраивать отношение has_many :through - если
 необходимо работать с моделью отношений как с независимым объектом.
 Если вам не нужно ничего делать с моделью отношений,
 проще настроить связь has_and_belongs_to_many (хотя нужно не забыть создать соединяющую таблицу в базе данных).




### Таблицы в БД

В этом примере мы разрабатываем приложение для агентства экскурсий. Для демонстрации
работы связей я создам несколько таблиц и свяжу их между собой.

Если интересно, то я использую следующие версии Ruby и Rails:

```
$ ruby -v
ruby 2.3.3p222 (2016-11-21) [x86_64-linux-gnu]
$ rails -v
Expected string default value for '--rc'; got false (boolean)
Rails 4.2.7.1
```
>В новых версиях Ruby и Ruby On Rails, команды имеют другой вид, но это не должно создать особых проблем.

####Создаем новое приложение

```
$ rails new agency
```

Давайте быстро создадим несколько таблиц в локальной базе данных. Мы можете использовать любую базу данных, которую пожелаете: ActiveRecord будет работать как с sqlite, так, например, и с MySQL и PostgreSQL. Для простоты примера я буду использовать базу sqlite. 

Мы храним некоторую информацию об экскурсии: в каком городе она проводится, сколько она стоит и кто 
экскурсовод.

Создадим таблицу экскурсии:
```
$ rails g model Trip title:string price:integer
```

Города:
```
$ rails g model City title:string
```

...и экскурсовода:

```
$ rails g model Guide name:string 
```

> по-умолчанию у столбца тип string, поэтому name:string можно заменить на просто name.

#### Модели и миграции

При выполнении каждой команды создались файлы миграции в db/migrate. У меня это выглядит так:

```
$ ls -l db/migrate

20180414103541_create_trips.rb
20180414103716_create_guides.rb
20180414103724_create_cities.rb
```

Кроме файлов миграции создались еще и файлы модели(кто бы мог подумать...) в app/models, 
однако содержимое каждого файла выглядит неубедительно:
```
class Trip < ActiveRecord::Base
end

```

Но если зайти в консоль и посмотреть, что там написано, то мы увидим нечто иное:
```
$ rails c
> Trip.connection
> Trip
=> Trip(id: integer,
		title: string,
 		price: integer, 
		created_at: datetime,
		updated_at: datetime)
```

Казалось бы, где информация о названии и стоимости экскурсии? 
Если "в двух словах", то потому, что
Active Record поймет и так, без необходимости задавать атрибуты явно. Если желаете
разобраться основательно, то можете почитать [комментарии к исходному коду](https://github.com/rails/rails/blob/master/activerecord/lib/active_record/base.rb)


Ладно, это не так важно, давайте лучше запустим миграцию:

```
$ rake db:migrate
```

#### Добавим несколько записей
Запускаем консоль и создаем парочку городов и экскурсоводов( часть вывода терминала я обрезаю):

```
$ rails console
> City.create(:title => 'Барнаул')
=> #<City id: 1, title: "Барнаул", created_at: "2018-04-14 10:55:32", updated_at: "2018-04-14 10:55:32">

>  Guide.create(:name => 'Иванов Иван')
=> #<Guide id: 1, name: "Иванов Иван", created_at: "2018-04-14 10:58:15", updated_at: "2018-04-14 10:58:15">

>  Guide.create(:name => 'Осетр Петр')
=> #<Guide id: 2, name: "Осетр Петр", created_at: "2018-04-14 10:58:50", updated_at: "2018-04-14 10:58:50">

```

Вроде все просто. Можно создавать записи об экскурсиях, прикручивать к моделям
контроллеры и представления и бежать сдавать лабораторную. Почти. В таблице Trip нет никакого намека
на город или экскурсовода.

## Связываем таблицы

#### Ассоциации
Помните тот список различных видов ассоциаций?
Давайте потренируемся на ~~кошках~~ has_many и belongs_to. С их помощью мы организуем связь "один-ко-многим" для таблиц Guide и Trip.

```
$ vim app/models/trip.rb

# у одной экскурсии один экскурсовод

class Trip < ActiveRecord::Base
	belongs_to :guide
end

$ vim app/models/guide.rb

# экскурсовод ведет много экскурсий

class Guide < ActiveRecord::Base
	has_many :trips
end
```

> Заметьте, что мы сделали связь "двусторонней". Это абсолютно нормально.
> Active Record попытается автоматически определить, что эти две модели образуют двунаправленную связь, основываясь на имени связи.

#### Реальные изменения
Просто так изменения не появятся, нужно создать миграцию:

```
$ rails generate migration guides
```

У нас появился новый файл миграции. Нам нужно указать, что таблицы в самом деле связаны:

```
class Guides < ActiveRecord::Migration
  def change
  	add_reference :trips, :guide, index: true
  end
end
```

Если бы у нас была совершенно новая миграция(если бы я тогда не написал rake db:migrate), то она могла выглядеть как-то:
```
class CreateTrips < ActiveRecord::Migration
  def change
    create_table :trips do |t|
      t.string     :title
      t.integer   :price
      t.references :guide
    end
  end
end
```

#### Консоль

Теперь в таблице "Trips" должен появиться еще один столбец: guides_id.
Открываем консоль и проверяем:
```
> Trip.column_names
=> ["id", "title", "price", "created_at", "updated_at", "guide_id"]
```

Заодно создадим запись:
```
> Trip.create(:title => "Прогулка по набережной", :price => 100, :guides_id => 1)
```

Все эти команды стоят SQL-запросы, которые мы можем посмотреть:
```
> Trip.where(:guides_id => 1)
=> "SELECT \"trips\".* FROM \"trips\" WHERE \"trips\".\"guide_id\" = 1"

> Trip.all.to_sql
=> "SELECT \"trips\".* FROM \"trips\""
```

Мы связали две таблицы, ура!

#### Сделать поле непустым
Но снова проблема: мы все равно можем создать экскурсию без информации о гиде.
При создании новой записи поле "guide_id" будет "nil". Пожалуй, при создании записи это поле необходимо сделать обязательным к заполнению.

Чтож, создаем новую миграцию и в ней прямо это укажем:

```
class GuidesNonNullable < ActiveRecord::Migration
  def change
      change_column_null(:trips, :guide_id, false)
  end
end
```

Попробуем создать экскурсию без информации об экскурсоводе:
```
> Trip.create(:title => "Экскурсия #1", :price => 50)
(0.1ms)  begin transaction
...
(0.1ms)  rollback transaction
```

Работает! В смысле, что не работает.


Кстати, можно удобно посмотреть значение по foreign-key:
```
> Trip.last.guide
```

Точно так же я свяжу города(City) с экскурсиями(Trip). Тут тоже связь "один-ко-многим", а код - 
абсолютно аналогичен. Вы можете открыть пример и убедиться в этом самостоятельно.

Любую другую связь можно организовать точно так же, смысл остается таким же, вам
нет необходимости выдумывать что-то новое для других типов связей.

### Scaffold
Стоит упомянуть, что описанные выше действия можно было сделать при помощи scaffold. Например:

```
$ rails g Trip guide:belongs_to title:string price:integer
```

А давайте попробуем и добавим отзывы к экскурсиям:
```
$ rails g scaffold Review trip:references name:string text:string
```
У каждого отзыва есть имя того, кто его оставил и, собственно, текст.
Смотрим модель:
```
$ cat app/models/review.rb

class Review < ActiveRecord::Base
  belongs_to :trip
end

```

...и миграцию:
```
$ cat db/migrations/20180415044804_create_reviews.rb

class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.references :trip, index: true, foreign_key: true
      t.string :name
      t.string :text

      t.timestamps null: false
    end
  end
end
```

> Вы должны понимать, что scaffold - это всего лишь инструмент в ваших руках.
> Вы его лишь используете, умело или нет - это уже ваше дело.


## Собственно, вот и все :)
## Литература
   * [Статья на Википедии о ActiveRecord](https://ru.wikipedia.org/wiki/ActiveRecord)
   * [Active Record Basics](http://guides.rubyonrails.org/active_record_basics.html)
   * [Active Record Query Interface](http://guides.rubyonrails.org/active_record_querying.html)
   * Active Record Associations([английский](http://guides.rubyonrails.org/association_basics.html), [русский](http://rusrails.ru/active-record-associations))
   * [Databases & Rails: Database Backed models with ActiveRecord](https://youtu.be/EU98yHB-_7A)
