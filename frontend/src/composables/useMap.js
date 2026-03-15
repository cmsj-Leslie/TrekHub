/** 高德地图封装 - 地图初始化、路线绘制、卫星切换、手动打点模式 */
import { ref, onUnmounted } from 'vue'

// 高德地图（仿两步路风格）
export function useMap(containerId, options = {}) {
  const map = ref(null)
  const polyline = ref(null)
  const markers = ref([])
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
      let satelliteOn = false
      sw.addEventListener('click', e => {
        const btn = e.target.closest('.lsw')
        if (!btn) return
        sw.querySelectorAll('.lsw').forEach(b => { b.style.background = '#fff'; b.style.color = '#333' })
        btn.style.background = '#1890ff'; btn.style.color = '#fff'

        if (btn.dataset.l === 's' && !satelliteOn) {
          map.value.setLayers([new AMap.TileLayer.Satellite(), new AMap.TileLayer.RoadNet()])
          satelliteOn = true
        } else if (btn.dataset.l === 'v') {
          map.value.setLayers([new AMap.TileLayer()])
          map.value.setMapStyle('amap://styles/fresh')
          satelliteOn = false
        }
      })
      document.getElementById(containerId)?.appendChild(sw)

      resolve(map.value)
    })
  }

  // 绘制路线（50个GPS点直连，不需要插值）
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

      // 清除旧内容
      if (polyline.value) map.value.remove(polyline.value)
      markers.value.forEach(m => map.value.remove(m))
      markers.value = []

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

  // 绘制模式（创建线路页面用）
  function enableDraw() {
    if (!map.value) return
    map.value.on('click', onMapClick)
  }
  function onMapClick(e) {
    const point = { lng: e.lnglat.getLng(), lat: e.lnglat.getLat() }
    drawPoints.value.push(point)
    const m = new AMap.Marker({ position: [point.lng, point.lat] })
    map.value.add(m)
    markers.value.push(m)
  }
  function disableDraw() { map.value?.off('click', onMapClick) }
  function clearDraw() {
    drawPoints.value = []
    markers.value.forEach(m => map.value?.remove(m))
    markers.value = []
    if (polyline.value) { map.value?.remove(polyline.value); polyline.value = null }
  }

  onUnmounted(() => { map.value?.destroy() })

  return { map, drawPoints, init, drawRoute, enableDraw, disableDraw, clearDraw }
}
