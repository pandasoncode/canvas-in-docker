#!/bin/bash
cd /var/www/canvas

# Check if DATABASE_POPULATION environment variable is set
if [ -n "$DATABASE_POPULATION" ]; then
    # Comando original
    original_command="bundle exec rake db:initial_setup"

    # Intentar ejecutar el comando original
    $original_command

    # Verificar si el comando original falló
    if [ $? -ne 0 ]; then
        # Acciones a realizar en caso de fallo

        # Mover archivos
        echo "Mover archivos"
        mv db/migrate/20210823222355_change_immersive_reader_allowed_on_to_on.rb .
        mv db/migrate/20210812210129_add_singleton_column.rb db/migrate/20111111214311_add_singleton_column.rb

        # Ejecutar yarn gulp rev
        echo "Ejecutar yarn gulp rev"
        yarn gulp rev

        # Ejecutar el comando original nuevamente
        echo "Ejecutar el comando original nuevamente"
        bundle exec rake db:initial_setup

        # Mover el archivo de vuelta
        echo "Mover el archivo de vuelta"
        mv 20210823222355_change_immersive_reader_allowed_on_to_on.rb db/migrate/.

        # Ejecutar rake db:migrate
        echo "Ejecutar rake db:migrate"
        bundle exec rake db:migrate
    fi
fi

/opt/nginx/sbin/nginx

# Iniciar canvas
echo "canvas is running..."
tail -f /var/www/canvas/log/production.log
