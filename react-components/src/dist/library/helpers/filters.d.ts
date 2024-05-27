declare const filters: {
    subjectAreas: {
        key: string;
        title: string;
        searchAreas: string[];
    }[];
    featureFilters: ({
        key: string;
        title: string;
        searchMaterialType: string;
        searchMaterialProperty?: undefined;
        searchSensors?: undefined;
    } | {
        key: string;
        title: string;
        searchMaterialProperty: string;
        searchMaterialType?: undefined;
        searchSensors?: undefined;
    } | {
        key: string;
        title: string;
        searchSensors: string[];
        searchMaterialType?: undefined;
        searchMaterialProperty?: undefined;
    })[];
    gradeFilters: {
        key: string;
        title: string;
        grades: string[];
        label: string;
        searchGroups: string[];
    }[];
};
export default filters;
