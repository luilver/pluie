namespace :route_task do

  # se ejecuta de 1ro
  task :create_route => :environment do
    create_route(0.018,'i1',Gateway.where(:name=>"infobip").first) unless Gateway.where(:name => "infobip").blank? or !Route.where(:name=>"i1").blank?
    create_route(0.01,'r2',Gateway.where(:name=>"routesms1").first) unless Gateway.where(:name=>"routesms1").blank? or !Route.where(:name=>"r2").blank?
    create_route(0.012,'r3',Gateway.where(:name=>"routesms").first) unless Gateway.where(:name=>"routesms").blank? or !Route.where(:name=>"r3").blank?
    create_route(0.0143,'c6',Gateway.where(:name=>"cardboardfish").first) unless Gateway.where(:name=>"cardboardfish").blank? or !Route.where(:name=>"c6").blank?
    create_route(0.02,'f5',Gateway.where(:name=>"fortytwo").first) unless Gateway.where(:name=>"fortytwo").blank? or !Route.where(:name=>"f5").blank?
  end

  # se ejcuta de 2da
  task :dependent_route=>:environment do  #creo las rutas dependientes por cada ruta default con precios menores

    routes_list= Route.all.select{ |r| ['i1','r2','r3','f5','c6'].include?(r.name) }
    routes_list.each do |r|
      value=0.001
      for i in 2.times
        if (r.price - value) > value_in_lost #precio no sea menor que valor de costo del proveedor mas caro
          create_route(r.price-value,r.name+(i+1).to_s,r.gateway) unless !Route.where(:name=>r.name+(i+1).to_s).blank?
          value=value+(value*2)
        end
      end
    end
  end

  # se ejecuta de 3ra
  task :transform_route =>:environment do

    list=name_concat(['i1','r2','r3'],2)  #genera una lista de nombres a partir de esa lista inicial hasta el elemento 2 de postfijo en cada nombre

    Route.all.each do |route|
        if !list.include?(route.name)
         case route.gateway.name
           when "infobip"
             r=give_routes('i1',2) # r es la lista de routas generadas a partir de i1
             ret=add_route_new(r,route)
             route.destroy unless !ret
             if !ret
               puts "La ruta del usuario #{User.find(route.user_id).username} con name: #{route.name}  tiene precio menor que la ruta mas barata: #{r.last.name} con el proveedor #{route.gateway.name}"
             end
           when  "routesms1"
             r=give_routes('r2',2)
             ret=add_route_new(r,route)
             route.destroy unless !ret
             if !ret
               puts "La ruta del usuario #{User.find(route.user_id).username} name: #{route.name} tiene precio menor que la ruta mas barata: #{r.last.name} con el proveedor #{route.gateway.name}"
             end
           when "routesms"
             r=give_routes('r3',2)
             ret=add_route_new(r,route)
             route.destroy unless !ret
             if !ret
               puts "La ruta del usuario #{User.find(route.user_id).username} name: #{route.name}  tiene precio menor que la ruta mas barata: #{r.last.name} con el proveedor #{route.gateway.name}"
             end
         end
        end
    end
  end


  task :add_user_pluie => :environment do
   begin
    Route.find_by_name('Pluie').users << User.find_by_email('pluie@openbgs.com')
    puts "User pluie insert succesfully in route Pluie"
   rescue

     puts "Error in insert"
   end

  end

  def create_route(price,name,gateway)
    Route.skip_callback(:save,:before,:min_value_route)
    r=Route.new
    r.price=price
    r.name=name
    r.gateway=gateway
    r.save
    Route.set_callback(:save,:before,:min_value_route)
  end


  def  value_in_lost
    Gateway.order(:price=>:desc).first.price
  end

  def name_concat(list,value)
    list_ret=[]
    list.each do |r|
    list_ret << r
      for i in value.times
        list_ret << (r + (i+1).to_s)
      end
    end
    list_ret
  end

  def give_routes(name,value)  #obtiene las rutas asociadas a ese nombre ordenadas de mayor a menor incluida la ruta base
     list=[]
     list << Route.where(:name=>name).first.name unless Route.where(:name=>name).blank?
     for i in value.times
      list << (name + (i+1).to_s)
     end
     r=Route.order(:price=>:desc).select {|r| list.include?(r.name)}
  end

  def add_route_new(routes_list, route_old)  #routes_list  es una lista de rutas ordenadas de mayor a menor
    #caso base
    if routes_list.first.price <= route_old.price  #route_list.first es la ruta por defecto asociada a ese gateway (las derivadas son menores)
      User.find(route_old.user_id).routes << routes_list.first
      User.find(route_old.user_id).save
      return true
    end

    if route_old.price >= routes_list.last.price and route_old.price < routes_list.first.price
        routes_list.each do |r|
          if r.price <= route_old.price
            User.find(route_old.user_id).routes << r
            User.find(route_old.user_id).save
            return true
          end
        end

    end
    return false   #la ruta antigua del usuario tiene un precio menor a la ruta mas barata por ese gateway.
  end

end
