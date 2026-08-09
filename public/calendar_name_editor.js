document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll(".calendar-name-editor").forEach(editor => {
    const text = editor.querySelector(".calendar-name-text");
    const input = editor.querySelector(".calendar-name-input");
    const editButton = editor.querySelector(".calendar-name-edit-btn");
    const updateUrl = editor.dataset.updateUrl;
    let isSavingName = false;

    if (!text || !input || !editButton || !updateUrl) {
      return;
    }

    const setCurrentName = name => {
      editor.dataset.currentName = name;
      text.textContent = name;
      input.value = name;

      const calendarCard = editor.closest(".calendar-card");
      const pdfButton = calendarCard && calendarCard.querySelector(".pdf-btn");

      if (pdfButton) {
        pdfButton.dataset.calendarName = name;
      }
    };

    const exitEdit = () => {
      input.hidden = true;
      text.hidden = false;
      editButton.hidden = false;
      editor.classList.remove("is-editing");
    };

    const enterEdit = () => {
      const currentName = editor.dataset.currentName || text.textContent.trim();

      input.value = currentName;
      text.hidden = true;
      editButton.hidden = true;
      input.hidden = false;
      editor.classList.add("is-editing");
      input.focus();
      input.select();
    };

    const saveName = async () => {
      if (isSavingName || input.hidden) {
        return;
      }

      const previousName = editor.dataset.currentName || text.textContent.trim() || "無題のカレンダー";
      const nextName = input.value.trim();

      if (input.dataset.skipSave === "true") {
        delete input.dataset.skipSave;
        input.value = previousName;
        exitEdit();
        return;
      }

      if (nextName === "" || nextName === previousName) {
        input.value = previousName;
        exitEdit();
        return;
      }

      isSavingName = true;
      editor.classList.add("is-saving");

      try {
        const response = await fetch(updateUrl, {
          method: "POST",
          credentials: "same-origin",
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: new URLSearchParams({ calendar_name: nextName })
        });

        const data = await response.json();

        if (!response.ok) {
          throw new Error(data.error || "Save failed");
        }

        setCurrentName(data.calendar_name || nextName);
      } catch (error) {
        console.error(error);
        input.value = previousName;
        alert("カレンダー名を保存できませんでした。");
      } finally {
        isSavingName = false;
        editor.classList.remove("is-saving");
        exitEdit();
      }
    };

    editButton.addEventListener("click", enterEdit);

    input.addEventListener("blur", saveName);
    input.addEventListener("focusout", saveName);
    input.addEventListener("change", saveName);

    input.addEventListener("keydown", event => {
      if (event.key === "Enter") {
        input.blur();
      }

      if (event.key === "Escape") {
        input.dataset.skipSave = "true";
        input.blur();
      }
    });

    document.addEventListener("pointerdown", event => {
      if (!editor.classList.contains("is-editing") || editor.contains(event.target)) {
        return;
      }

      saveName();
    });
  });
});
