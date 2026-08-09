let draggedImageUrl = null;

const selectedDropZones = new Set();

function zoneHasImage(zone) {
  return zone.querySelector('.day-image') !== null;
}

function setZoneSelected(zone, isSelected) {
  if (!zone) return;

  if (isSelected) {
    selectedDropZones.add(zone);
  } else {
    selectedDropZones.delete(zone);
  }

  zone.classList.toggle('drop-zone-selected', isSelected);
  zone.setAttribute('aria-selected', String(isSelected));
}

function toggleZoneSelection(zone) {
  if (zoneHasImage(zone)) return;
  setZoneSelected(zone, !selectedDropZones.has(zone));
}

function clearSelectedZones() {
  selectedDropZones.forEach(zone => {
    zone.classList.remove('drop-zone-selected');
    zone.setAttribute('aria-selected', 'false');
  });
  selectedDropZones.clear();
}

function createCalendarImage(imageUrl) {
  const newImg = document.createElement('img');
  newImg.src = imageUrl;
  newImg.classList.add('day-image');
  return newImg;
}

function addImageToZone(zone, imageUrl) {
  if (!zone || zoneHasImage(zone)) return false;

  zone.appendChild(createCalendarImage(imageUrl));
  addZoneDeleteButton(zone);
  return true;
}

function selectedEmptyZones() {
  return Array.from(selectedDropZones).filter(zone => {
    return document.body.contains(zone) && !zoneHasImage(zone);
  });
}

function applyImageToZones(imageUrl, fallbackZone = null) {
  const targetZones = selectedEmptyZones();
  if (targetZones.length === 0 && fallbackZone && !zoneHasImage(fallbackZone)) {
    targetZones.push(fallbackZone);
  }

  const addedCount = targetZones.reduce((count, zone) => {
    return addImageToZone(zone, imageUrl) ? count + 1 : count;
  }, 0);

  if (addedCount > 0) clearSelectedZones();
  return addedCount > 0;
}

// パレット側：dragstartでURLを保持
document.querySelectorAll('.palette-image').forEach(img => {
  img.addEventListener('dragstart', (e) => {
    draggedImageUrl = e.target.src;
    e.dataTransfer.effectAllowed = 'copy';
  });
  img.addEventListener('dragend', () => {
    draggedImageUrl = null;
  });

  img.addEventListener('click', () => {
    applyImageToZones(img.src);
  });
});

function addZoneDeleteButton(zone) {
  if (zone.querySelector('.zone-btn')) return;

  const btn = document.createElement('button');
  btn.type = 'button';
  btn.classList.add('zone-btn');
  btn.textContent = '×';

  btn.addEventListener('click', (event) => {
    event.stopPropagation();
    setZoneSelected(zone, false);
  zone.innerHTML = '';
  });
  
   zone.appendChild(btn);
  }

// カレンダー側：drop-zone をドロップ可能にする
document.querySelectorAll('.drop-zone').forEach(zone => {
  zone.tabIndex = 0;
  zone.setAttribute('aria-selected', 'false');

  zone.addEventListener('click', (event) => {
    if (event.target.closest('.zone-btn')) return;
    toggleZoneSelection(zone);
  });

  zone.addEventListener('keydown', (event) => {
    if (event.key !== 'Enter' && event.key !== ' ') return;

    event.preventDefault();
    toggleZoneSelection(zone);
  });
  zone.addEventListener('dragover', (e) => {
    // すでに画像が入っていたら、dragover自体を無効化（=ドロップできない）
    const selectedTargets = selectedEmptyZones();
    if (selectedTargets.length === 0 && zoneHasImage(zone)) return;


    e.preventDefault(); // これがないとdropされない
  });

  zone.addEventListener('drop', (e) => {
    e.preventDefault();
    if (!draggedImageUrl) return;

  applyImageToZones(draggedImageUrl, zone);
  });
});

if (document.querySelector('.save-button')) {
  document.querySelectorAll('.drop-zone').forEach(zone => {
    if (zone.querySelector('.day-image')) {
      addZoneDeleteButton(zone);
    }
  });
}


function buildCalendarJson() {
  const result = {};

  document.querySelectorAll('.day-column').forEach(column => {
    const dayKey = column.dataset.day; // "mon", "tue" など
    const zones = column.querySelectorAll('.drop-zone');

    result[dayKey] = Array.from(zones).map(zone => {
      const img = zone.querySelector('img');
      if (!img) return null;

      const url = new URL(img.src, window.location.origin);

      // 同一オリジンならパスだけ保存
      if (url.origin === window.location.origin) {
        return url.pathname;
      }

      // 外部URL（Cloudinaryなど）はフルURLで保存
      return url.href;
    });
  });

  return result;
}

function buildDayCalendarJson() {
  const result = {};

  document.querySelectorAll('.time-column').forEach(column => {
    const timeKey = column.dataset.time; // "1"〜"7"

    // 🔹 time-display を取得
    const timeText =
      column.querySelector('.time-display')?.textContent?.trim() || "";

    // 🔹 drop-zone の画像
    const zones = column.querySelectorAll('.drop-zone');
    const images = Array.from(zones).map(zone => {
      const img = zone.querySelector('img');
      if (!img) return null;

      const url = new URL(img.src, window.location.origin);
      return url.origin === window.location.origin
        ? url.pathname
        : url.href;
    });

    // 🔹 time + images をまとめて保存
    result[timeKey] = {
      time: timeText,
      images: images
    };
  });

  return result;
}

const slideDown = function(el) {
  el.style.height = 'auto'; //いったんautoに
  let h = el.offsetHeight;  //autoにした要素から高さを取得
  el.animate({ // 高さ0から取得した高さまでのアニメーション
    height: [ 0, h + 'px' ]
  }, {
    duration: 300, // アニメーションの時間
   });
   el.style.height = 'auto';  //ブラウザの表示幅を途中で閲覧者が変えた時を考慮してautoに戻す
   el.setAttribute('aria-hidden', 'false');  //WAI-ARIA対応、閉じた状態であることを支援技術に伝える
};

// 要素を非表示にする関数
const slideUp = function(el) {
  let h = el.offsetHeight;
  el.style.height = h + 'px';
  el.animate({
    height: [ h + 'px', 0]
  }, {
    duration: 300,
   });
   el.style.height = 0;
   el.setAttribute('aria-hidden', 'true');  //WAI-ARIA対応、開いた状態であることを支援技術に伝える
};


const clockBtn = document.getElementById('clockBtn');
const content = document.getElementById('clockList');

clockBtn.addEventListener('click', () => {
  const isHidden = content.getAttribute('aria-hidden') === 'true';

  if (isHidden) {
    slideDown(content);

  } else {
    slideUp(content);

  }
});

if (clockBtn && content) {
  clockBtn.addEventListener('click', () => {
    const isHidden = content.getAttribute('aria-hidden') === 'true';

    if (isHidden) {
      slideDown(content);

    } else {
      slideUp(content);

    }
  });
}

function buildMonthCalendarJson() {
  const result = {};

  document.querySelectorAll('.day-cell').forEach(cell => {
    const key = cell.dataset.date;
    if (!key) return;
    
    const zones = cell.querySelectorAll('.drop-zone');
    const images = Array.from(zones).map(zone => {
      const img = zone.querySelector('img');
      if (!img) return null;

      const url = new URL(img.src, location.origin);
      return url.origin === location.origin ? url.pathname : url.href;
    });

    result[key] = images.length === 1 ? images[0] : images;
    
  });

  return result;
}

function hourLabel(value) {
  const t = parseTime(value);
  return t ? `${t.h}時` : "--時--";
}

function setHourPickerOpen(picker, isOpen) {
  const toggle = picker?.querySelector("[data-hour-picker-toggle]");
  const options = picker?.querySelector(".hour-picker-options");
  if (!toggle || !options) return;

  toggle.setAttribute("aria-expanded", String(isOpen));
  options.hidden = !isOpen;
  picker.classList.toggle("open", isOpen);
}

function closeHourPickers(exceptPicker = null) {
  document.querySelectorAll("[data-hour-picker]").forEach(picker => {
    if (picker !== exceptPicker) setHourPickerOpen(picker, false);
  });
}

function setHourPickerValue(input, value, emitChange = false) {
  if (!input) return;

  const picker = input.closest("[data-hour-picker]");
  const normalizedValue = value === undefined || value === null ? "" : String(value);
  input.value = normalizedValue;

  if (picker) {
    const toggle = picker.querySelector("[data-hour-picker-toggle]");
    const options = picker.querySelectorAll("[data-hour-value]");
    if (toggle) toggle.textContent = hourLabel(normalizedValue);

    options.forEach(option => {
      const isSelected = option.dataset.hourValue === normalizedValue;
      option.classList.toggle("selected", isSelected);
      option.setAttribute("aria-selected", String(isSelected));
    });
  }

  if (emitChange) input.dispatchEvent(new Event("change", { bubbles: true }));
}