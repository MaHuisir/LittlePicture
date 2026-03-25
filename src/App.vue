<template>
  <div class="app">
    <!-- 背景装饰 -->
    <div class="background-decoration">
      <div class="gradient-orb orb-1"></div>
      <div class="gradient-orb orb-2"></div>
      <div class="gradient-orb orb-3"></div>
    </div>

    <!-- 主容器 -->
    <div class="container">
      <!-- 头部 -->
      <header class="header">
        <div class="header-content">
          <div class="logo-section">
            <div class="logo-icon">🖼️</div>
            <div>
              <h1 class="logo-text">小图宝</h1>
              <p class="logo-subtitle">智能图片压缩工具</p>
            </div>
          </div>
          <div class="header-stats">
            <div class="stat-item">
              <span class="stat-label">已处理</span>
              <span class="stat-value">{{ totalProcessed }}</span>
            </div>
            <div class="stat-item">
              <span class="stat-label">节省空间</span>
              <span class="stat-value">{{ formatSize(totalSaved) }}</span>
            </div>
          </div>
        </div>
      </header>

      <!-- 主要内容区 -->
      <main class="main-content">
        <!-- 上传区域 -->
        <section class="upload-section">
          <div 
            class="upload-area"
            :class="{ 'drag-over': isDragging }"
            @dragover.prevent="isDragging = true"
            @dragleave.prevent="isDragging = false"
            @drop.prevent="handleDrop"
          >
            <div class="upload-content">
              <div class="upload-icon">📤</div>
              <h2>拖拽或点击上传图片</h2>
              <p>支持 JPG、PNG、WebP、GIF 等格式</p>
              <p class="upload-limit">单个文件最大 100MB</p>
              <input 
                ref="fileInput"
                type="file" 
                multiple 
                accept="image/*"
                @change="handleFileSelect"
                class="file-input"
              />
              <button class="btn btn-primary" @click="$refs.fileInput.click()">
                选择文件
              </button>
            </div>
          </div>
        </section>

        <!-- 控制面板 -->
        <section v-if="files.length > 0" class="control-panel">
          <div class="control-grid">
            <div class="control-item">
              <label class="control-label">
                <span>压缩质量</span>
                <span class="quality-value">{{ quality }}%</span>
              </label>
              <input 
                v-model.number="quality" 
                type="range" 
                min="10" 
                max="100" 
                class="slider"
                @input="updatePreview"
              />
              <div class="quality-hints">
                <span v-if="quality >= 80" class="hint hint-high">高质量</span>
                <span v-else-if="quality >= 50" class="hint hint-medium">中等质量</span>
                <span v-else class="hint hint-low">高压缩</span>
              </div>
            </div>

            <div class="control-item">
              <label class="control-label">
                <span>最大宽度</span>
                <span class="size-value">{{ maxWidth }}px</span>
              </label>
              <input 
                v-model.number="maxWidth" 
                type="range" 
                min="100" 
                max="4000" 
                step="100"
                class="slider"
                @input="updatePreview"
              />
            </div>

            <div class="control-item">
              <label class="control-label">
                <span>输出格式</span>
              </label>
              <select v-model="outputFormat" class="select-input" @change="updatePreview">
                <option value="auto">自动选择</option>
                <option value="jpeg">JPEG</option>
                <option value="png">PNG</option>
                <option value="webp">WebP</option>
              </select>
            </div>
          </div>

          <!-- 批量操作按钮 -->
          <div class="batch-actions">
            <button class="btn btn-secondary" @click="selectAll">
              {{ allSelected ? '取消全选' : '全选' }}
            </button>
            <button 
              class="btn btn-success" 
              @click="compressAll"
              :disabled="selectedFiles.length === 0 || isCompressing"
            >
              {{ isCompressing ? '压缩中...' : `压缩 (${selectedFiles.length})` }}
            </button>
            <button 
              class="btn btn-info" 
              @click="downloadAll"
              :disabled="compressedFiles.length === 0"
            >
              批量下载 ({{ compressedFiles.length }})
            </button>
            <button class="btn btn-danger" @click="clearAll">
              清空
            </button>
          </div>
        </section>

        <!-- 文件列表 -->
        <section v-if="files.length > 0" class="files-section">
          <div class="files-header">
            <h3>{{ files.length }} 个文件</h3>
            <div class="view-toggle">
              <button 
                :class="['view-btn', { active: viewMode === 'grid' }]"
                @click="viewMode = 'grid'"
              >
                ⊞
              </button>
              <button 
                :class="['view-btn', { active: viewMode === 'list' }]"
                @click="viewMode = 'list'"
              >
                ≡
              </button>
            </div>
          </div>

          <div :class="['files-container', `view-${viewMode}`]">
            <div 
              v-for="(file, index) in files" 
              :key="index"
              class="file-card"
              :class="{ 
                selected: file.selected,
                compressed: file.compressed,
                error: file.error
              }"
            >
              <!-- 复选框 -->
              <div class="file-checkbox">
                <input 
                  type="checkbox" 
                  :checked="file.selected"
                  @change="toggleFileSelect(index)"
                  class="checkbox-input"
                />
              </div>

              <!-- 预览 -->
              <div class="file-preview">
                <img 
                  v-if="file.preview" 
                  :src="file.preview" 
                  :alt="file.name"
                  class="preview-img"
                />
                <div v-else class="preview-placeholder">
                  {{ getFileTypeIcon(file.type) }}
                </div>
              </div>

              <!-- 信息 -->
              <div class="file-info">
                <div class="file-name" :title="file.name">{{ file.name }}</div>
                
                <div class="file-stats">
                  <span class="stat">{{ formatSize(file.size) }}</span>
                  <span v-if="file.compressed" class="stat compressed-size">
                    → {{ formatSize(file.compressedSize) }}
                  </span>
                </div>

                <div v-if="file.compressed" class="compression-ratio">
                  <div class="ratio-bar">
                    <div 
                      class="ratio-fill" 
                      :style="{ width: file.compressionRatio + '%' }"
                    ></div>
                  </div>
                  <span class="ratio-text">
                    {{ (100 - file.compressionRatio).toFixed(1) }}% 压缩
                  </span>
                </div>

                <div v-if="file.error" class="error-message">
                  ⚠️ {{ file.error }}
                </div>

                <div v-if="file.compressing" class="compressing-indicator">
                  <div class="spinner"></div>
                  <span>压缩中...</span>
                </div>
              </div>

              <!-- 操作按钮 -->
              <div class="file-actions">
                <button 
                  v-if="!file.compressed && !file.compressing"
                  class="action-btn compress-btn"
                  @click="compressFile(index)"
                  title="压缩此文件"
                >
                  ⚡
                </button>
                <button 
                  v-if="file.compressed"
                  class="action-btn download-btn"
                  @click="downloadFile(index)"
                  title="下载"
                >
                  ⬇️
                </button>
                <button 
                  class="action-btn delete-btn"
                  @click="removeFile(index)"
                  title="删除"
                >
                  ✕
                </button>
              </div>
            </div>
          </div>
        </section>

        <!-- 空状态 -->
        <section v-if="files.length === 0" class="empty-state">
          <div class="empty-icon">🎯</div>
          <h3>还没有上传任何图片</h3>
          <p>上传图片开始压缩吧！</p>
        </section>
      </main>

      <!-- 页脚 -->
      <footer class="footer">
        <p>小图宝 © 2024 | 100% 本地处理，无需上传服务器 | <a href="#" @click.prevent="showAbout = true">关于</a></p>
      </footer>
    </div>

    <!-- 关于弹窗 -->
    <div v-if="showAbout" class="modal-overlay" @click="showAbout = false">
      <div class="modal" @click.stop>
        <button class="modal-close" @click="showAbout = false">✕</button>
        <h2>关于小图宝</h2>
        <div class="modal-content">
          <p><strong>版本：</strong> 1.0.0</p>
          <p><strong>功能：</strong></p>
          <ul>
            <li>✓ 支持 100MB 以内的图片压缩</li>
            <li>✓ 按百分比调整压缩质量</li>
            <li>✓ 智能预估压缩后文件大小</li>
            <li>✓ 批量选择、压缩、下载</li>
            <li>✓ 完全本地处理，隐私安全</li>
            <li>✓ PC 和移动端完美适配</li>
          </ul>
          <p><strong>技术栈：</strong> Vue 3 + Vite + browser-image-compression</p>
          <p><strong>隐私说明：</strong> 所有图片处理均在本地浏览器中进行，不会上传到任何服务器。</p>
        </div>
      </div>
    </div>

    <!-- 提示信息 -->
    <transition name="toast">
      <div v-if="toast.show" :class="['toast', `toast-${toast.type}`]">
        {{ toast.message }}
      </div>
    </transition>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import imageCompression from 'browser-image-compression'

// 状态
const files = ref([])
const quality = ref(75)
const maxWidth = ref(1920)
const outputFormat = ref('auto')
const isDragging = ref(false)
const isCompressing = ref(false)
const viewMode = ref('grid')
const showAbout = ref(false)
const fileInput = ref(null)

// 提示信息
const toast = ref({ show: false, message: '', type: 'info' })

// 计算属性
const selectedFiles = computed(() => files.value.filter(f => f.selected))
const allSelected = computed(() => files.value.length > 0 && files.value.every(f => f.selected))
const compressedFiles = computed(() => files.value.filter(f => f.compressed))
const totalProcessed = computed(() => compressedFiles.value.length)
const totalSaved = computed(() => {
  return compressedFiles.value.reduce((sum, f) => sum + (f.size - f.compressedSize), 0)
})

// 方法
const handleDrop = (e) => {
  isDragging.value = false
  const droppedFiles = Array.from(e.dataTransfer.files).filter(f => f.type.startsWith('image/'))
  addFiles(droppedFiles)
}

const handleFileSelect = (e) => {
  const selectedFiles = Array.from(e.target.files)
  addFiles(selectedFiles)
  e.target.value = ''
}

const addFiles = async (newFiles) => {
  for (const file of newFiles) {
    // 检查文件大小
    if (file.size > 100 * 1024 * 1024) {
      showToast(`文件 ${file.name} 超过 100MB 限制`, 'error')
      continue
    }

    // 创建预览
    const preview = await createPreview(file)

    files.value.push({
      file,
      name: file.name,
      type: file.type,
      size: file.size,
      preview,
      selected: true,
      compressed: false,
      compressing: false,
      compressedSize: 0,
      compressionRatio: 0,
      compressedFile: null,
      error: null
    })
  }

  showToast(`已添加 ${newFiles.length} 个文件`, 'success')
}

const createPreview = (file) => {
  return new Promise((resolve) => {
    const reader = new FileReader()
    reader.onload = (e) => resolve(e.target.result)
    reader.readAsDataURL(file)
  })
}

const toggleFileSelect = (index) => {
  files.value[index].selected = !files.value[index].selected
}

const selectAll = () => {
  const shouldSelect = !allSelected.value
  files.value.forEach(f => f.selected = shouldSelect)
}

const compressFile = async (index) => {
  const fileItem = files.value[index]
  fileItem.compressing = true
  fileItem.error = null

  try {
    const options = {
      maxSizeMB: 100,
      maxWidthOrHeight: maxWidth.value,
      useWebWorker: true,
      fileType: outputFormat.value === 'auto' ? fileItem.type : `image/${outputFormat.value}`
    }

    // 根据质量调整压缩参数
    if (quality.value < 50) {
      options.initialQuality = 0.5
    } else if (quality.value < 75) {
      options.initialQuality = 0.7
    } else {
      options.initialQuality = 0.9
    }

    const compressedFile = await imageCompression(fileItem.file, options)
    
    fileItem.compressedFile = compressedFile
    fileItem.compressedSize = compressedFile.size
    fileItem.compressionRatio = Math.round((compressedFile.size / fileItem.size) * 100)
    fileItem.compressed = true

    showToast(`${fileItem.name} 压缩完成`, 'success')
  } catch (error) {
    fileItem.error = error.message || '压缩失败'
    showToast(`${fileItem.name} 压缩失败`, 'error')
  } finally {
    fileItem.compressing = false
  }
}

const compressAll = async () => {
  if (selectedFiles.value.length === 0) return

  isCompressing.value = true
  let successCount = 0

  for (const fileItem of selectedFiles.value) {
    if (!fileItem.compressed && !fileItem.compressing) {
      const index = files.value.indexOf(fileItem)
      await compressFile(index)
      successCount++
    }
  }

  isCompressing.value = false
  showToast(`已压缩 ${successCount} 个文件`, 'success')
}

const downloadFile = (index) => {
  const fileItem = files.value[index]
  if (!fileItem.compressedFile) return

  const url = URL.createObjectURL(fileItem.compressedFile)
  const a = document.createElement('a')
  a.href = url
  a.download = `compressed_${fileItem.name}`
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
}

const downloadAll = async () => {
  const compressedList = compressedFiles.value
  if (compressedList.length === 0) return

  if (compressedList.length === 1) {
    downloadFile(files.value.indexOf(compressedList[0]))
    return
  }

  // 多个文件时，逐个下载
  for (const fileItem of compressedList) {
    const index = files.value.indexOf(fileItem)
    downloadFile(index)
    // 延迟以避免浏览器阻止
    await new Promise(resolve => setTimeout(resolve, 200))
  }

  showToast(`已下载 ${compressedList.length} 个文件`, 'success')
}

const removeFile = (index) => {
  files.value.splice(index, 1)
}

const clearAll = () => {
  if (confirm('确定要清空所有文件吗？')) {
    files.value = []
    showToast('已清空所有文件', 'info')
  }
}

const updatePreview = () => {
  // 更新预览（可选）
}

const formatSize = (bytes) => {
  if (bytes === 0) return '0 B'
  const k = 1024
  const sizes = ['B', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return Math.round((bytes / Math.pow(k, i)) * 100) / 100 + ' ' + sizes[i]
}

const getFileTypeIcon = (type) => {
  if (type.includes('jpeg') || type.includes('jpg')) return '🖼️'
  if (type.includes('png')) return '🎨'
  if (type.includes('webp')) return '✨'
  if (type.includes('gif')) return '🎬'
  return '📷'
}

const showToast = (message, type = 'info') => {
  toast.value = { show: true, message, type }
  setTimeout(() => {
    toast.value.show = false
  }, 3000)
}

onMounted(() => {
  // 初始化
})
</script>

<style scoped>
:root {
  --primary: #00d4ff;
  --primary-dark: #0099cc;
  --secondary: #7b2cbf;
  --success: #10b981;
  --warning: #f59e0b;
  --danger: #ef4444;
  --info: #3b82f6;
  --bg-dark: #0a0e17;
  --bg-card: #111827;
  --bg-card-hover: #1a2332;
  --text-primary: #e8f4f8;
  --text-secondary: #8ba3b8;
  --border: #1e3a5f;
  --glow: rgba(0, 212, 255, 0.3);
}

.app {
  min-height: 100vh;
  position: relative;
  overflow-x: hidden;
}

/* 背景装饰 */
.background-decoration {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  z-index: 0;
}

.gradient-orb {
  position: absolute;
  border-radius: 50%;
  filter: blur(80px);
  opacity: 0.15;
}

.orb-1 {
  width: 400px;
  height: 400px;
  background: linear-gradient(135deg, #00d4ff, #0099cc);
  top: -100px;
  left: -100px;
  animation: float 20s ease-in-out infinite;
}

.orb-2 {
  width: 300px;
  height: 300px;
  background: linear-gradient(135deg, #7b2cbf, #c084fc);
  bottom: 100px;
  right: -50px;
  animation: float 25s ease-in-out infinite reverse;
}

.orb-3 {
  width: 250px;
  height: 250px;
  background: linear-gradient(135deg, #00d4ff, #7b2cbf);
  top: 50%;
  right: 10%;
  animation: float 30s ease-in-out infinite;
}

@keyframes float {
  0%, 100% { transform: translate(0, 0); }
  50% { transform: translate(30px, -30px); }
}

/* 容器 */
.container {
  position: relative;
  z-index: 1;
  max-width: 1400px;
  margin: 0 auto;
  padding: 20px;
}

/* 头部 */
.header {
  margin-bottom: 40px;
  padding: 30px;
  background: rgba(17, 24, 39, 0.6);
  border: 1px solid rgba(0, 212, 255, 0.1);
  border-radius: 20px;
  backdrop-filter: blur(10px);
  animation: slideDown 0.6s ease-out;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 40px;
}

.logo-section {
  display: flex;
  align-items: center;
  gap: 15px;
}

.logo-icon {
  font-size: 48px;
  animation: bounce 2s ease-in-out infinite;
}

.logo-text {
  font-size: 32px;
  font-weight: 700;
  background: linear-gradient(135deg, #00d4ff, #7b2cbf);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  margin: 0;
}

.logo-subtitle {
  font-size: 14px;
  color: var(--text-secondary);
  margin: 5px 0 0 0;
}

.header-stats {
  display: flex;
  gap: 30px;
}

.stat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.stat-label {
  font-size: 12px;
  color: var(--text-secondary);
  text-transform: uppercase;
  letter-spacing: 1px;
  margin-bottom: 5px;
}

.stat-value {
  font-size: 24px;
  font-weight: 700;
  color: var(--primary);
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes bounce {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-10px); }
}

/* 上传区域 */
.upload-section {
  margin-bottom: 40px;
}

.upload-area {
  border: 2px dashed rgba(0, 212, 255, 0.3);
  border-radius: 20px;
  padding: 60px 20px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s ease;
  background: rgba(17, 24, 39, 0.3);
  position: relative;
  overflow: hidden;
}

.upload-area::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: radial-gradient(circle at center, rgba(0, 212, 255, 0.05) 0%, transparent 70%);
  pointer-events: none;
}

.upload-area:hover {
  border-color: rgba(0, 212, 255, 0.6);
  background: rgba(17, 24, 39, 0.5);
  box-shadow: 0 0 30px rgba(0, 212, 255, 0.2);
}

.upload-area.drag-over {
  border-color: var(--primary);
  background: rgba(0, 212, 255, 0.1);
  box-shadow: 0 0 40px rgba(0, 212, 255, 0.3);
  transform: scale(1.02);
}

.upload-content {
  position: relative;
  z-index: 1;
}

.upload-icon {
  font-size: 64px;
  margin-bottom: 20px;
  animation: pulse 2s ease-in-out infinite;
}

.upload-area h2 {
  font-size: 24px;
  margin: 0 0 10px 0;
  color: var(--text-primary);
}

.upload-area p {
  color: var(--text-secondary);
  margin: 5px 0;
  font-size: 14px;
}

.upload-limit {
  font-size: 12px;
  color: var(--warning);
  margin-top: 10px;
}

.file-input {
  display: none;
}

@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.1); }
}

/* 按钮 */
.btn {
  padding: 12px 24px;
  border: none;
  border-radius: 10px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-primary {
  background: linear-gradient(135deg, var(--primary), var(--primary-dark));
  color: var(--bg-dark);
  box-shadow: 0 0 20px rgba(0, 212, 255, 0.3);
}

.btn-primary:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 0 30px rgba(0, 212, 255, 0.5);
}

.btn-secondary {
  background: rgba(123, 44, 191, 0.2);
  color: var(--primary);
  border: 1px solid rgba(123, 44, 191, 0.5);
}

.btn-secondary:hover:not(:disabled) {
  background: rgba(123, 44, 191, 0.3);
  border-color: rgba(123, 44, 191, 0.8);
}

.btn-success {
  background: linear-gradient(135deg, var(--success), #059669);
  color: white;
}

.btn-success:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 0 20px rgba(16, 185, 129, 0.3);
}

.btn-info {
  background: linear-gradient(135deg, var(--info), #2563eb);
  color: white;
}

.btn-info:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 0 20px rgba(59, 130, 246, 0.3);
}

.btn-danger {
  background: rgba(239, 68, 68, 0.2);
  color: var(--danger);
  border: 1px solid rgba(239, 68, 68, 0.5);
}

.btn-danger:hover:not(:disabled) {
  background: rgba(239, 68, 68, 0.3);
  border-color: rgba(239, 68, 68, 0.8);
}

/* 控制面板 */
.control-panel {
  background: rgba(17, 24, 39, 0.6);
  border: 1px solid rgba(0, 212, 255, 0.1);
  border-radius: 20px;
  padding: 30px;
  margin-bottom: 40px;
  backdrop-filter: blur(10px);
  animation: slideUp 0.6s ease-out;
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.control-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 30px;
  margin-bottom: 30px;
}

.control-item {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.control-label {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 14px;
  font-weight: 600;
  color: var(--text-primary);
}

.quality-value,
.size-value {
  color: var(--primary);
  font-weight: 700;
}

.slider {
  width: 100%;
  height: 6px;
  border-radius: 3px;
  background: linear-gradient(90deg, rgba(0, 212, 255, 0.2), rgba(123, 44, 191, 0.2));
  outline: none;
  -webkit-appearance: none;
  appearance: none;
}

.slider::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 18px;
  height: 18px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--primary), var(--primary-dark));
  cursor: pointer;
  box-shadow: 0 0 15px rgba(0, 212, 255, 0.4);
  transition: all 0.2s ease;
}

.slider::-webkit-slider-thumb:hover {
  transform: scale(1.2);
  box-shadow: 0 0 25px rgba(0, 212, 255, 0.6);
}

.slider::-moz-range-thumb {
  width: 18px;
  height: 18px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--primary), var(--primary-dark));
  cursor: pointer;
  border: none;
  box-shadow: 0 0 15px rgba(0, 212, 255, 0.4);
  transition: all 0.2s ease;
}

.slider::-moz-range-thumb:hover {
  transform: scale(1.2);
  box-shadow: 0 0 25px rgba(0, 212, 255, 0.6);
}

.quality-hints {
  display: flex;
  gap: 8px;
}

.hint {
  font-size: 11px;
  padding: 4px 8px;
  border-radius: 4px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.hint-high {
  background: rgba(16, 185, 129, 0.2);
  color: var(--success);
}

.hint-medium {
  background: rgba(245, 158, 11, 0.2);
  color: var(--warning);
}

.hint-low {
  background: rgba(239, 68, 68, 0.2);
  color: var(--danger);
}

.select-input {
  padding: 10px 12px;
  background: rgba(17, 24, 39, 0.8);
  border: 1px solid rgba(0, 212, 255, 0.2);
  border-radius: 8px;
  color: var(--text-primary);
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.select-input:hover {
  border-color: rgba(0, 212, 255, 0.5);
}

.select-input:focus {
  outline: none;
  border-color: var(--primary);
  box-shadow: 0 0 15px rgba(0, 212, 255, 0.2);
}

.batch-actions {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

/* 文件列表 */
.files-section {
  background: rgba(17, 24, 39, 0.6);
  border: 1px solid rgba(0, 212, 255, 0.1);
  border-radius: 20px;
  padding: 30px;
  backdrop-filter: blur(10px);
  animation: slideUp 0.6s ease-out;
}

.files-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.files-header h3 {
  margin: 0;
  font-size: 18px;
  color: var(--text-primary);
}

.view-toggle {
  display: flex;
  gap: 8px;
}

.view-btn {
  width: 36px;
  height: 36px;
  border: 1px solid rgba(0, 212, 255, 0.2);
  background: transparent;
  color: var(--text-secondary);
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 16px;
}

.view-btn:hover {
  border-color: rgba(0, 212, 255, 0.5);
  color: var(--primary);
}

.view-btn.active {
  background: rgba(0, 212, 255, 0.2);
  border-color: var(--primary);
  color: var(--primary);
}

.files-container {
  display: grid;
  gap: 16px;
}

.view-grid {
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
}

.view-list {
  grid-template-columns: 1fr;
}

.file-card {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px;
  background: rgba(17, 24, 39, 0.4);
  border: 1px solid rgba(0, 212, 255, 0.1);
  border-radius: 12px;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.file-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, rgba(0, 212, 255, 0.05) 0%, transparent 100%);
  opacity: 0;
  transition: opacity 0.3s ease;
  pointer-events: none;
}

.file-card:hover {
  border-color: rgba(0, 212, 255, 0.3);
  background: rgba(17, 24, 39, 0.6);
}

.file-card:hover::before {
  opacity: 1;
}

.file-card.selected {
  border-color: var(--primary);
  background: rgba(0, 212, 255, 0.1);
}

.file-card.compressed {
  border-color: rgba(16, 185, 129, 0.3);
}

.file-card.error {
  border-color: rgba(239, 68, 68, 0.3);
}

.file-checkbox {
  flex-shrink: 0;
}

.checkbox-input {
  width: 20px;
  height: 20px;
  cursor: pointer;
  accent-color: var(--primary);
}

.file-preview {
  flex-shrink: 0;
  width: 80px;
  height: 80px;
  border-radius: 8px;
  overflow: hidden;
  background: rgba(0, 0, 0, 0.3);
  display: flex;
  align-items: center;
  justify-content: center;
}

.preview-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.preview-placeholder {
  font-size: 32px;
}

.file-info {
  flex: 1;
  min-width: 0;
}

.file-name {
  font-weight: 600;
  color: var(--text-primary);
  margin-bottom: 8px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.file-stats {
  display: flex;
  gap: 12px;
  font-size: 13px;
  color: var(--text-secondary);
  margin-bottom: 8px;
}

.stat {
  display: flex;
  align-items: center;
}

.compressed-size {
  color: var(--success);
  font-weight: 600;
}

.compression-ratio {
  display: flex;
  align-items: center;
  gap: 8px;
}

.ratio-bar {
  flex: 1;
  height: 4px;
  background: rgba(0, 212, 255, 0.1);
  border-radius: 2px;
  overflow: hidden;
}

.ratio-fill {
  height: 100%;
  background: linear-gradient(90deg, var(--success), var(--primary));
  transition: width 0.3s ease;
}

.ratio-text {
  font-size: 12px;
  color: var(--success);
  font-weight: 600;
  white-space: nowrap;
}

.error-message {
  font-size: 12px;
  color: var(--danger);
  margin-top: 8px;
}

.compressing-indicator {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  color: var(--primary);
  margin-top: 8px;
}

.spinner {
  width: 12px;
  height: 12px;
  border: 2px solid rgba(0, 212, 255, 0.3);
  border-top-color: var(--primary);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.file-actions {
  display: flex;
  gap: 8px;
  flex-shrink: 0;
}

.action-btn {
  width: 36px;
  height: 36px;
  border: none;
  background: rgba(0, 212, 255, 0.1);
  color: var(--primary);
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.action-btn:hover {
  background: rgba(0, 212, 255, 0.2);
  transform: scale(1.1);
}

.compress-btn:hover {
  background: rgba(16, 185, 129, 0.2);
  color: var(--success);
}

.download-btn:hover {
  background: rgba(59, 130, 246, 0.2);
  color: var(--info);
}

.delete-btn:hover {
  background: rgba(239, 68, 68, 0.2);
  color: var(--danger);
}

/* 空状态 */
.empty-state {
  text-align: center;
  padding: 80px 20px;
  color: var(--text-secondary);
}

.empty-icon {
  font-size: 64px;
  margin-bottom: 20px;
  animation: float 3s ease-in-out infinite;
}

.empty-state h3 {
  font-size: 24px;
  color: var(--text-primary);
  margin-bottom: 10px;
}

/* 页脚 */
.footer {
  text-align: center;
  padding: 30px 20px;
  color: var(--text-secondary);
  font-size: 13px;
  margin-top: 60px;
}

.footer a {
  color: var(--primary);
  text-decoration: none;
  transition: color 0.3s ease;
}

.footer a:hover {
  color: var(--primary-dark);
  text-decoration: underline;
}

/* 模态框 */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

.modal {
  background: rgba(17, 24, 39, 0.95);
  border: 1px solid rgba(0, 212, 255, 0.2);
  border-radius: 16px;
  padding: 40px;
  max-width: 500px;
  width: 90%;
  max-height: 80vh;
  overflow-y: auto;
  backdrop-filter: blur(10px);
  position: relative;
  animation: slideUp 0.3s ease;
}

.modal-close {
  position: absolute;
  top: 20px;
  right: 20px;
  width: 32px;
  height: 32px;
  border: none;
  background: rgba(0, 212, 255, 0.1);
  color: var(--primary);
  border-radius: 8px;
  cursor: pointer;
  font-size: 18px;
  transition: all 0.3s ease;
}

.modal-close:hover {
  background: rgba(0, 212, 255, 0.2);
  transform: rotate(90deg);
}

.modal h2 {
  margin: 0 0 20px 0;
  color: var(--text-primary);
  font-size: 24px;
}

.modal-content {
  color: var(--text-secondary);
  line-height: 1.8;
}

.modal-content p {
  margin: 12px 0;
}

.modal-content ul {
  margin: 12px 0;
  padding-left: 20px;
}

.modal-content li {
  margin: 8px 0;
}

.modal-content strong {
  color: var(--primary);
}

/* 提示信息 */
.toast {
  position: fixed;
  bottom: 30px;
  right: 30px;
  padding: 16px 24px;
  border-radius: 10px;
  font-size: 14px;
  font-weight: 600;
  z-index: 2000;
  animation: slideInRight 0.3s ease;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
}

@keyframes slideInRight {
  from {
    opacity: 0;
    transform: translateX(100px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

.toast-enter-active,
.toast-leave-active {
  transition: all 0.3s ease;
}

.toast-enter-from,
.toast-leave-to {
  opacity: 0;
  transform: translateX(100px);
}

.toast-info {
  background: rgba(59, 130, 246, 0.2);
  color: var(--info);
  border: 1px solid rgba(59, 130, 246, 0.3);
}

.toast-success {
  background: rgba(16, 185, 129, 0.2);
  color: var(--success);
  border: 1px solid rgba(16, 185, 129, 0.3);
}

.toast-error {
  background: rgba(239, 68, 68, 0.2);
  color: var(--danger);
  border: 1px solid rgba(239, 68, 68, 0.3);
}

/* 响应式设计 */
@media (max-width: 768px) {
  .container {
    padding: 12px;
  }

  .header {
    padding: 20px;
    margin-bottom: 30px;
  }

  .header-content {
    flex-direction: column;
    gap: 20px;
  }

  .logo-text {
    font-size: 24px;
  }

  .header-stats {
    width: 100%;
    justify-content: space-around;
  }

  .upload-area {
    padding: 40px 20px;
  }

  .upload-icon {
    font-size: 48px;
  }

  .upload-area h2 {
    font-size: 18px;
  }

  .control-grid {
    grid-template-columns: 1fr;
    gap: 20px;
  }

  .batch-actions {
    flex-direction: column;
  }

  .batch-actions .btn {
    width: 100%;
    justify-content: center;
  }

  .view-grid {
    grid-template-columns: 1fr;
  }

  .file-card {
    flex-wrap: wrap;
  }

  .file-preview {
    width: 60px;
    height: 60px;
  }

  .file-actions {
    width: 100%;
    margin-top: 12px;
    justify-content: flex-end;
  }

  .modal {
    width: 95%;
    padding: 30px 20px;
  }

  .toast {
    bottom: 20px;
    right: 20px;
    left: 20px;
  }

  .files-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }
}

@media (max-width: 480px) {
  .logo-section {
    gap: 10px;
  }

  .logo-icon {
    font-size: 36px;
  }

  .logo-text {
    font-size: 20px;
  }

  .logo-subtitle {
    font-size: 12px;
  }

  .stat-value {
    font-size: 18px;
  }

  .btn {
    padding: 10px 16px;
    font-size: 12px;
  }

  .file-card {
    gap: 12px;
    padding: 12px;
  }

  .file-preview {
    width: 50px;
    height: 50px;
  }

  .file-name {
    font-size: 13px;
  }

  .file-stats {
    font-size: 12px;
  }
}
</style>
