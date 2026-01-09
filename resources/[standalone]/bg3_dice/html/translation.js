;(()=>{
  const LANGS = {
    en: {
      title: "D20 CHECK",
      rolling: "ROLLING…",
      dc: (v)=> `DC ${v}`,
      success: "SUCCESS",
      fail: "FAIL",
      advantage: "ADVANTAGE",
      disadvantage: "DISADVANTAGE",
      rolls: (a,b)=> `ROLLS: ${a} • ${b}`,
      picked: (v)=> `(picked ${v})`,
      dash: "—"
    },
    hu: {
      title: "D20 ELLENŐRZÉS",
      rolling: "PÖRGÉS…",
      dc: (v)=> `CÉL ${v}`,
      success: "SIKER",
      fail: "SIKERTELEN",
      advantage: "ELŐNY",
      disadvantage: "HÁTRÁNY",
      rolls: (a,b)=> `DOBÁSOK: ${a} • ${b}`,
      picked: (v)=> `(választott ${v})`,
      dash: "—"
    },
    de: {
      title: "D20 PRÜFUNG",
      rolling: "WIRD GEWÜRFELT…",
      dc: (v)=> `SG ${v}`,
      success: "ERFOLG",
      fail: "FEHLSCHLAG",
      advantage: "VORTEIL",
      disadvantage: "NACHTEIL",
      rolls: (a,b)=> `WÜRFEL: ${a} • ${b}`,
      picked: (v)=> `(gewählt ${v})`,
      dash: "—"
    },
    fr: {
      title: "TEST D20",
      rolling: "LANCEMENT…",
      dc: (v)=> `DD ${v}`,
      success: "RÉUSSITE",
      fail: "ÉCHEC",
      advantage: "AVANTAGE",
      disadvantage: "DÉSAVANTAGE",
      rolls: (a,b)=> `LANCÉS : ${a} • ${b}`,
      picked: (v)=> `(retenu ${v})`,
      dash: "—"
    },
    es: {
      title: "PRUEBA D20",
      rolling: "TIRANDO…",
      dc: (v)=> `CD ${v}`,
      success: "ÉXITO",
      fail: "FALLO",
      advantage: "VENTAJA",
      disadvantage: "DESVENTAJA",
      rolls: (a,b)=> `TIRADAS: ${a} • ${b}`,
      picked: (v)=> `(elegido ${v})`,
      dash: "—"
    },
    pt: {
      title: "TESTE D20",
      rolling: "ROLANDO…",
      dc: (v)=> `CD ${v}`,
      success: "SUCESSO",
      fail: "FALHA",
      advantage: "VANTAGEM",
      disadvantage: "DESVANTAGEM",
      rolls: (a,b)=> `ROLAGENS: ${a} • ${b}`,
      picked: (v)=> `(escolhido ${v})`,
      dash: "—"
    },
    it: {
      title: "PROVA D20",
      rolling: "TIRANDO…",
      dc: (v)=> `CD ${v}`,
      success: "SUCCESSO",
      fail: "FALLIMENTO",
      advantage: "VANTAGGIO",
      disadvantage: "SVANTAGGIO",
      rolls: (a,b)=> `TIRI: ${a} • ${b}`,
      picked: (v)=> `(scelto ${v})`,
      dash: "—"
    },
    pl: {
      title: "TEST K20",
      rolling: "RZUT…",
      dc: (v)=> `ST ${v}`,
      success: "SUKCES",
      fail: "PORAŻKA",
      advantage: "PREMIA",
      disadvantage: "KARA",
      rolls: (a,b)=> `RZUTY: ${a} • ${b}`,
      picked: (v)=> `(wybrano ${v})`,
      dash: "—"
    },
    tr: {
      title: "D20 KONTROLÜ",
      rolling: "ZAR ATIYOR…",
      dc: (v)=> `ZG ${v}`,
      success: "BAŞARILI",
      fail: "BAŞARISIZ",
      advantage: "AVANTAJ",
      disadvantage: "DEZAVANTAJ",
      rolls: (a,b)=> `ATLAR: ${a} • ${b}`,
      picked: (v)=> `(seçilen ${v})`,
      dash: "—"
    },
    ru: {
      title: "ПРОВЕРКА D20",
      rolling: "БРОСОК…",
      dc: (v)=> `СЛ ${v}`,
      success: "УСПЕХ",
      fail: "ПРОВАЛ",
      advantage: "ПРЕИМУЩЕСТВО",
      disadvantage: "НЕДОСТАТОК",
      rolls: (a,b)=> `БРОСКИ: ${a} • ${b}`,
      picked: (v)=> `(выбран ${v})`,
      dash: "—"
    }
  };

  const I18N = {
    lang: 'en',
    setLanguage(code){
      this.lang = LANGS[code] ? code : 'en';
    },
    t(key, ...args){
      const pack = LANGS[this.lang] || LANGS.en;
      const val = pack[key];
      if (typeof val === 'function') return val(...args);
      return (val != null) ? val : (LANGS.en[key] || key);
    }
  };

  window.__I18N = I18N;
})();
