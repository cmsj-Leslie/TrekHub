/** 高德地图封装 - 地图初始化、路线绘制、卫星切换、手动打点模式 */
import { ref, onUnmounted } from 'vue'

// 高德地图（仿两步路风格）
export function useMap(containerId, options = {}) {
  const map = ref(null)
  const polyline = ref(null)
  const markers = ref([])       // 路线展示用标记（起点/终点/描边线）
  const clickMarkers = ref([])  // 绘制模式下的点击标记（序号圆点）
  const drawPoints = ref([])

  function init() {
    return new Promise(resolve => {
      if (typeof AMap === 'undefined') {
        console.warn('高德地图 SDK 未加载')
        return resolve(null)
      }

      map.value = new AMap.Map(containerId, {
        zoom: options.zoom || 13,
        center: options.center || [116.397428, 39.90923],
        mapStyle: 'amap://styles/fresh'
      })

      map.value.addControl(new AMap.Scale())
      map.value.addControl(new AMap.ToolBar({ position: 'LT' }))

      // 高德矢量 / 卫星影像 切换 (仿两步路)
      const sw = document.createElement('div')
      sw.style.cssText = 'position:absolute;top:10px;right:10px;z-index:200;display:flex;border-radius:4px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.15)'
      sw.innerHTML = `
        <button class="lsw active" data-l="v" style="padding:6px 14px;border:none;background:#1890ff;color:#fff;font-size:13px;cursor:pointer;font-weight:500">高德矢量</button>
        <button class="lsw" data-l="s" style="padding:6px 14px;border:none;background:#fff;color:#333;font-size:13px;cursor:pointer;border-left:1px solid #e0e0e0">卫星影像</button>
      `
      // 卫星图层 + 路网标注图层（预创建，初始隐藏）
      const satelliteLayer = new AMap.TileLayer.Satellite({ visible: false })
      const roadNetLayer = new AMap.TileLayer.RoadNet({ visible: false })
      map.value.add([satelliteLayer, roadNetLayer])
      sw.addEventListener('click', e => {
        const btn = e.target.closest('.lsw')
        if (!btn) return
        sw.querySelectorAll('.lsw').forEach(b => { b.style.background = '#fff'; b.style.color = '#333' })
        btn.style.background = '#1890ff'; btn.style.color = '#fff'

        if (btn.dataset.l === 's') {
          satelliteLayer.show()
          roadNetLayer.show()  // 路网标注层：白色文字+深色描边，专为卫星底图设计
        } else {
          satelliteLayer.hide()
          roadNetLayer.hide()
          map.value.setMapStyle('amap://styles/fresh')
        }
      })
      document.getElementById(containerId)?.appendChild(sw)

      resolve(map.value)
    })
  }

  // 清除路线展示层（折线 + 起终点标记），不影响绘制打点
  function clearRouteDisplay() {
    if (polyline.value) { map.value?.remove(polyline.value); polyline.value = null }
    markers.value.forEach(m => map.value?.remove(m))
    markers.value = []
  }

  // 绘制路线（GPS 点直连）
  function drawRoute(points) {
    if (!map.value || !points?.length) return

    try {
      // 转成 AMap.LngLat，过滤非法值
      const path = []
      for (const p of points) {
        const lng = parseFloat(p.lng), lat = parseFloat(p.lat)
        if (lng && lat && lng > 70 && lng < 140 && lat > 15 && lat < 55) {
          path.push(new AMap.LngLat(lng, lat))
        }
      }
      if (path.length < 2) return

      // 清除旧的路线展示
      clearRouteDisplay()

      // 白色底线（描边效果）
      const outline = new AMap.Polyline({
        path,
        strokeColor: '#ffffff',
        strokeWeight: 7,
        strokeOpacity: 0.6,
        lineJoin: 'round',
        lineCap: 'round'
      })
      map.value.add(outline)
      markers.value.push(outline)

      // 红色路线
      polyline.value = new AMap.Polyline({
        path,
        strokeColor: '#e74c3c',
        strokeWeight: 4,
        strokeOpacity: 0.95,
        lineJoin: 'round',
        lineCap: 'round'
      })
      map.value.add(polyline.value)

      // 起点
      const startM = new AMap.Marker({
        position: path[0],
        content: '<div style="background:#27ae60;color:#fff;padding:3px 8px;border-radius:10px;font-size:12px;font-weight:bold;box-shadow:0 2px 6px rgba(0,0,0,.3);border:2px solid #fff;white-space:nowrap">🚩 起点</div>',
        offset: new AMap.Pixel(-30, -15)
      })
      const endM = new AMap.Marker({
        position: path[path.length - 1],
        content: '<div style="background:#e74c3c;color:#fff;padding:3px 8px;border-radius:10px;font-size:12px;font-weight:bold;box-shadow:0 2px 6px rgba(0,0,0,.3);border:2px solid #fff;white-space:nowrap">🏁 终点</div>',
        offset: new AMap.Pixel(-30, -15)
      })
      map.value.add([startM, endM])
      markers.value.push(startM, endM)

      // 自动适配视野
      map.value.setFitView([polyline.value], false, [60, 60, 60, 60])
    } catch (err) {
      console.error('drawRoute:', err)
    }
  }

  // ========== 绘制模式（创建线路页面用）==========

  function enableDraw() {
    if (!map.value) return
    map.value.on('click', onMapClick)
  }

  function onMapClick(e) {
    const point = { lng: e.lnglat.getLng(), lat: e.lnglat.getLat() }
    drawPoints.value.push(point)
    // 绘制带序号的小圆点标记
    const idx = drawPoints.value.length
    const m = new AMap.Marker({
      position: [point.lng, point.lat],
      content: `<div style="width:22px;height:22px;border-radius:50%;background:#2d8cf0;color:#fff;font-size:10px;font-weight:bold;display:flex;align-items:center;justify-content:center;border:2px solid #fff;box-shadow:0 2px 6px rgba(0,0,0,.3)">${idx}</div>`,
      offset: new AMap.Pixel(-11, -11)
    })
    map.value.add(m)
    clickMarkers.value.push(m)

    // 两个点以上时自动绘制连线预览
    if (drawPoints.value.length >= 2) {
      drawRoute(drawPoints.value)
    }
  }

  function disableDraw() { map.value?.off('click', onMapClick) }

  // 撤销最后一个绘制点
  function undoLastPoint() {
    if (!drawPoints.value.length || !map.value) return
    // 移除最后一个坐标
    drawPoints.value.pop()
    // 从地图上移除最后一个点标记
    const lastMarker = clickMarkers.value.pop()
    if (lastMarker) map.value.remove(lastMarker)
    // 重新绘制连线 或 清除连线
    if (drawPoints.value.length >= 2) {
      drawRoute(drawPoints.value)
    } else {
      clearRouteDisplay()
    }
  }

  // 清除所有绘制内容（点标记 + 路线 + 停止绘制模式）
  function clearDraw() {
    drawPoints.value = []
    // 清除绘制点标记
    clickMarkers.value.forEach(m => map.value?.remove(m))
    clickMarkers.value = []
    // 清除路线展示
    clearRouteDisplay()
    // 停止绘制模式
    disableDraw()
  }

  // 根据地名定位地图（高德地理编码）
  function gotoPlace(keyword) {
    if (!map.value || !keyword?.trim()) return
    // 动态加载 Geocoder 插件（index.html 中未预加载）
    AMap.plugin('AMap.Geocoder', () => {
      const geocoder = new AMap.Geocoder({ city: '全国' })
      geocoder.getLocation(keyword.trim(), (status, result) => {
        if (status === 'complete' && result.geocodes?.length) {
          const { lng, lat } = result.geocodes[0].location
          map.value.setZoomAndCenter(13, [lng, lat], false, 600)
        }
      })
    })
  }

  onUnmounted(() => { map.value?.destroy() })

  return { map, drawPoints, init, drawRoute, enableDraw, disableDraw, clearDraw, undoLastPoint, gotoPlace }
}
