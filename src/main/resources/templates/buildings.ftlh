<!DOCTYPE html>
<html>
<head>
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
          integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY="
          crossorigin=""/>
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
            integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo="
            crossorigin=""></script>
    <title>RENTAL PREMISES</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f8f8f8;
            color: #333;
            margin: 0;
            padding: 0;
        }

        h2, h3, h4 {
            color: red;
        }

        form {
            margin-bottom: 20px;
        }

        input[type="text"],
        input[type="number"],
        input[type="submit"],
        input[type="file"] {
            padding: 8px;
            margin: 5px 0;
            border: 1px solid #ccc;
            border-radius: 5px;
            box-sizing: border-box;
        }

        input[type="file"]:hover {
            background-color: darkgrey;
        }

        input[type="submit"] {
            background-color: red;
            color: white;
            cursor: pointer;
        }

        input[type="submit"]:hover {
            background-color: darkred;
        }

        hr {
            border: none;
            border-top: 1px solid #ccc;
            margin: 20px 0;
        }

        #map {
            max-width: 800px;
            padding: 20px;
            background-color: #fff;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            margin: 10px auto;
        }

        div.container {
            max-width: 800px;
            margin: 10px auto;
            padding: 20px;
            background-color: #fff;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }

        form.buildings {
            text-align: center; /* Center align form elements */
        }

        form.buildings label {
            display: inline-block; /* Make labels display as inline-block */
            width: 120px; /* Set a fixed width for labels */
            text-align: left; /* Align labels to the left */
            margin-bottom: 5px; /* Add some space between labels and inputs */
        }

        form.buildings input[type="text"],
        form.buildings input[type="number"],
        form.buildings input[type="file"] {
            display: inline-block; /* Make inputs display as inline-block */
            width: calc(100% - 170px); /* Set the width of inputs, accounting for label width and margin */
            max-width: 300px; /* Limit maximum width of inputs */
            margin-bottom: 10px; /* Add some space below inputs */
        }

        form.buildings input[type="submit"] {
            margin-top: 10px; /* Add space above the submit button */
        }

        h3.add {
            text-align: center;
        }

        .heading {
            display: inline-block; /* Display heading as inline-block */
            margin-right: 65%; /* Add space between heading and button */
        }

        .heading:hover {
            color: darkred;
        }

        .login-form {
            display: inline-block; /* Display form as inline-block */
            margin: 0; /* Remove default margin */
        }

        .login-button {
            margin: 0; /* Remove default margin */
        }

        .search {
            text-align: right;
        }

        .search-error {
            text-align: right;
        }

        .building-info {
            border: 1px solid #ccc;
            border-radius: 5px;
            padding: 10px;
            margin-bottom: 20px;
            background-color: #f9f9f9;
        }

        .building-info h4 {
            color: #333;
            margin-bottom: 5px;
        }

        .building-info p {
            margin: 5px 0;
        }

    </style>
</head>
<body>
<div class="container">
    <script>
        function checkFiles(input) {

            if (input.files && input.files.length > 5) {
                alert("Вы можете загрузить не более 5 файлов.");
                input.value = ''; // Очистка выбранных файлов
                return;
            }
            if (input.files && input.files.length > 0) {
                for (let i = 0; i < input.files.length; i++) {
                    var file = input.files[i];
                    var fileSize = file.size; // Размер файла в байтах
                    var maxSize = 5 * 1024 * 1024; // Максимальный размер файла в байтах (5 MB)

                    if (!['image/jpeg', 'image/jpg', 'image/png', 'image/gif'].includes(file.type)) {
                        alert('Пожалуйста, выберите файлы только с расширением .jpg, .jpeg, .png или .gif.');
                        input.value = ''; // Очистка выбранного файла
                        return;
                    }

                    if (fileSize > maxSize) {
                        alert('Размер файла должен быть меньше 5 МБ.');
                        input.value = ''; // Очистка выбранного файла
                        return;
                    }
                }
            }
        }
    </script>
    <script>
        function validateForm() {
            var name = document.getElementById("name").value;
            var location = document.getElementById("location").value;
            var price = document.getElementById("price").value;
            var frontFiles = document.getElementById("frontFile").files;
            var entranceFiles = document.getElementById("entranceFile").files;
            var interiorFiles = document.getElementById("interiorFile").files;

            // Check if name, location, and price are empty
            if (name.trim() === "") {
                alert("Пожалуйста, заполните поле 'Название'.");
                return false; // Prevent form submission
            }

            if (location.trim() === "") {
                alert("Пожалуйста, заполните поле 'Расположение'.");
                return false; // Prevent form submission
            }

            if (price.trim() === "") {
                alert("Пожалуйста, заполните поле 'Цена'.");
                return false; // Prevent form submission
            }

            // Check if price is non-negative
            if (price < 0) {
                alert("Цена должна быть неотрицательной.");
                return false; // Prevent form submission
            }

            // Check if at least one file has been added
            if (frontFiles.length === 0) {
                alert("Пожалуйста, загрузите картинку фасада.");
                return false; // Prevent form submission
            }

            return true; // Allow form submission
        }
    </script>
    <script>
        function validateSearchForm() {
            var name = document.getElementById("searchName").value;
            var location = document.getElementById("searchLocation").value;
            var price = document.getElementById("searchPrice").value;

            // Check if any search field is not empty
            if (name.trim() === "" && location.trim() === "" && price.trim() === "") {
                alert("Пожалуйста, заполните хотя бы одно поле для поиска.");
                return false; // Prevent form submission
            }

            return true; // Allow form submission
        }
    </script>
    <h2 class="heading">
        <a href="/" style="text-decoration: none; color: inherit;">RENTAL PREMISES</a>
    </h2>
    <#if user.username??>
        <form action="/logout" method="post" class="login-form">
            <h3 class="heading">
                <a href="/user/${user.id}" style="text-decoration: none; color: inherit;">Имя
                    пользователя: ${user.username}</a>
            </h3>
            <input type="submit" value="Выйти из аккаунта" class="login-button"/>
        </form>
        <#if user.isAdmin()>
            <form action="/admin" method="get" class="login-form">
                <input type="submit" value="Панель администратора" class="admin-button"/>
            </form>
        </#if>
    <#else>
        <form action="/login" method="get" class="login-form">
            <input type="submit" value="Вход" class="login-button"/>
        </form>
    </#if>
    <!--фильтрация зданий-->
    <form action="/" method="get" class="search" onsubmit="return validateSearchForm()">
        <label for="searchName">Поиск по названию здания:</label>
        <input type="text" id="searchName" name="name"/><br>
        <label for="searchLocation">Поиск по локации здания:</label>
        <input type="text" id="searchLocation" name="location"/><br>
        <label for="searchPrice">Поиск по цене здания:</label>
        <input type="number" id="searchPrice" name="price"/><br>
        <label for="approvedCheckbox">Статус:</label>
        <input type="checkbox" id="approvedCheckbox" name="approved"><br>
        <input type="submit" value="Поиск"/>
    </form>
    <#list buildings as building>
        <!--реализованно при помощи freeMarker, buildings передаётся через buildings(Model model)-->
        <!--цикл for, проходимся по каждому зданию-->
        <div class="building-info">
            <#list building.images as img>
                <#if img.isPreviewImage()>
                    <a href="/images/${img.id}" target="_blank">
                        <img src="/images/${img.id}" height="250px">
                    </a>
                </#if>
            </#list>
            <h4>Название: ${building.name}</h4>
            <p>Расположение: ${building.location}</p>
            <p>Цена: ${building.price}</p>
            <p>Владелец: ${building.user.username}</p>
            <p>Описание: ${building.description}</p>
            <#if building.approved>
                <p>Статус: одобрено</p>
            <#else>
                <p>Статус: неодобрено</p>
            </#if>
            <form action="/building/${building.id}" method="get" class="login-form">
                <input type="submit" value="Подробнее..." class="login-button"/>
            </form>
        </div>
    <#else>
        <h3 class="search-error">Ничего не найдено</h3>
    </#list>
    <#if user.username??>
        <h3 class="add">Внести новое помещение</h3>
        <!--Передаёт JSON методом POST, спринг получает и автоматически конверирует в Building-->
        <!--Передаёт Building в buildingCreate(Building building)-->
        <form action="/building/create" method="post" class="buildings" enctype="multipart/form-data"
              onsubmit="return validateForm()">
            <label for="name">Название:</label>
            <input type="text" id="name" name="name"/><br><br>
            <label for="location">Расположение:</label>
            <input type="text" id="location" name="location"/><br><br>
            <label for="price">Цена:</label>
            <input type="number" id="price" name="price"/><br><br>
            <label for="description">Описание:</label>
            <input type="text" id="description" name="description"/><br><br>
            <label for="frontFile">Фасад:</label>
            <input type="file" id="frontFile" name="frontFile" accept=".jpg, .jpeg, .png, .gif" multiple
                   onchange="checkFiles(this)" max="5"><br><br>
            <label for="entranceFile">Вход:</label>
            <input type="file" id="entranceFile" name="entranceFile" accept=".jpg, .jpeg, .png, .gif" multiple
                   onchange="checkFiles(this)" max="5"><br><br>
            <label for="interiorFile">Интерьер:</label>
            <input type="file" id="interiorFile" name="interiorFile" accept=".jpg, .jpeg, .png, .gif" multiple
                   onchange="checkFiles(this)" max="5"><br><br>
            <input type="submit" value="Добавить помещение"/>
        </form>
    <#else>
        <h4> Войдите в аккаунт, чтобы добавить помещение </h4>
    </#if>
</div>

<div id="map" style="height: 400px;"></div> <!-- Контейнер карты -->
<script>
    // создание карты
    var map = L.map('map').setView([59.95, 30.40], 10); // Устанавливаем координаты центра карты и уровень масштабирования
    // добавление слоя тайлов
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(map);
    // список мапов с данными о зданиях
    var mapBuildings = [
        <#list buildings as building>
        {
            id: ${building.id},
            name: "${building.name}",
            strLocation: "${building.location}",
            price: "${building.price}",
            username: "${building.user.username}",
            description: "${building.description}"
        }<#sep>,
        </#list>
    ];

    for (var i = 0; i < mapBuildings.length; i++) {
        makeMarker(mapBuildings[i]);
    }

    async function makeMarker(building) {
        const response = await fetch("https://nominatim.openstreetmap.org/search?format=json&q=" + building["strLocation"]);
        const jsonLocation = await response.json();
        const location = jsonLocation[0];
        L.marker([location["lat"], location["lon"]]).addTo(map)
            .bindPopup(
                '<h3>' + building["name"] + '</h3>' + building["strLocation"] + '<br><form action="/building/'
                + building.id + '" method="get" class="login-form"><input type="submit" value="Подробнее..." class="login-button"/></form>'
            );
    }
</script>
</body>
</html>