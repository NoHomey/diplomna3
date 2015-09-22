class Controller {
  constructor() {
    var vm = this;
    vm.data = [3, 2, 1, 4, 5];
    vm.ivo = 'ivo';
  }
}

var moduleName = 'appController';

var config = {
  templateUrl : '/views/view-app.html',
  controller : moduleName,
  controllerAs : 'vm'
};

var appController = {
  moduleName : moduleName,
  config : config,
  controller : Controller
};

export var appController = appController;
