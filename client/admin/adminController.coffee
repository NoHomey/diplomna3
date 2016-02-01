module.exports = ($controller, $scope, RESTHelperService, $filter, dateService, showDescriptionService, getStatusOptionsService, notificationService, confirmService, showCalculatedPriceService) ->
  @$inject = ["$controller", "$scope", "RESTHelperService", "$filter", "dateService", "showDescriptionService", "getStatusOptionsService", "notificationService", "confirmService", "showCalculatedPriceService"]

  controller = $controller "ordersInterface",
    "$scope": $scope
    "RESTHelperService": RESTHelperService
    "$filter": $filter
    "dateService": dateService
    "showDescriptionService": showDescriptionService
    "getStatusOptionsService": getStatusOptionsService
    "notificationService": notificationService
    "confirmService": confirmService

  controller.adminPanel = "adminPanelView"

  init = ->

    RESTHelperService.visit.find (res) ->

      controller.listOfVisits = res.visits

      stopStatistics = $scope.$watch "ordersCtrl.listOfOrders", (orders) ->

        if not orders? then return

        beggin = controller.fromDate

        end = controller.toDate

        if end < beggin then [beggin, end] = [end, beggin]

        [controller.fromDate, controller.toDate] = [beggin, end]

        it = dateService.iterator beggin, end

        gap = end.getMonth() - beggin.getMonth()

        years = end.getFullYear() - beggin.getFullYear() + 1

        normalizate =  Math.abs (Math.floor end.getDate() / 3) - (Math.floor beggin.getDate() / 3)

        diff = Math.abs (Math.floor ((3 * gap * years) + 3 - normalizate) / 3) + 3

        interval =
          current: diff
          label: ""

        intervals = {}

        statisticData = (search) ->
          data =
            count: 0
            delivered: 0
            revenue: 0
            visits: 0
            users: 0

          for order in orders
            if order.orderDate is search
              data.count++
              data.revenue += order.price
              if order.status is "delivered"
                data.delivered++

          for visit in controller.listOfVisits
            if visit.date is search
              data.visits++
              if visit.user then data.users++

          data

        buildIntervals = (date) ->
          label = dateService.format date
          data = statisticData label

          if interval.current is diff
            interval.current = 0
            interval.label = label
            intervals[label] =
              count: 0
              delivered: 0
              revenue: 0
              visits: 0
              users: 0
          else
            label = interval.label
            interval.current++

          for info in ["count", "delivered", "revenue", "visits", "users"]
            intervals[label][info] += data[info]

        buildIntervals it.value while it.inc()

        buildCharts = ->

          labels = []

          charts =
            count:
              series: ["line-orders-count", "line-delivered"]
              data: [[], []]
            revenue:
              series: ["line-revenue"]
              data: [[]]
            visit:
              series: ["line-uniqe-visits", "line-uniqe-users"]
              data: [[], []]

          for label, data of intervals
            labels.push label
            charts.count.data[0].push data.count
            charts.count.data[1].push data.delivered
            charts.revenue.data[0].push data.revenue
            charts.visit.data[0].push data.visits
            charts.visit.data[1].push data.users

          for chart in ["count", "revenue", "visit"]
            charts[chart].labels = labels

          charts

        controller.charts = buildCharts()

      stopRemove = $scope.$on "user-removed", (event, user) ->
        controller.fullListOfOrders = controller.fullListOfOrders.filter (element) ->
          element.user._id isnt user
        controller.filterFn()

      $scope.$on "$destroy", ->
        stopStatistics()
        stopRemove()

  controller.doAction = (event, order) ->
    showDescriptionService event,
      info:
        id: order._id
        status: order.status
        admin: yes
        user: order.user._id
        price: order.price

  controller.afterChoose = (event, order, stencil, callback) ->
    if order.status is "new"
      locals = order: order, stencil: stencil
      showCalculatedPriceService event, locals, update: -> controller.doAction event, order
    else callback()

  init()

  controller
